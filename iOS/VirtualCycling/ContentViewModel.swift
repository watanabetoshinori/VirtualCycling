//
//  ContentViewModel.swift
//  VirtualCycling
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Foundation
import Combine

/// コンテンツビューのビューモデル
class ContentViewModel: ObservableObject {

    /// サイクルメーター
    var meter: CycleMeter

    /// WebViewのモデル
    var webViewModel: WebViewModel

    /// 画面に表示する経過時刻
    @Published var time = "00:00";

    /// 画面に表示する距離
    @Published var distance = "0.00";

    /// 画面に表示する消費カロリー
    @Published var calorie = "0.0";

    /// 画面に表示する回転数
    @Published var cycle = "0";

    /// 画面に表示する顔の傾き
    @Published var face = "0.0";

    /// Combineのキャンセル
    private var cancellables = [AnyCancellable]()

    /// ビューモデルの初期化
    init(meter: CycleMeter, webViewModel: WebViewModel) {
        self.meter = meter
        self.webViewModel = webViewModel

        // 経過時間
        meter.$duration.sink { (value) in
            let minutes = value / 1000 / 60
            let seconds = (value - (6000 * minutes)) / 1000
            self.time = String(format: "%02d:%02d", Int(minutes), Int(seconds))
        }
        .store(in: &cancellables)

        // 距離
        meter.$distance.sink { (value) in
            self.distance = String(format: "%0.2f", value)
        }
        .store(in: &cancellables)

        // 消費カロリー
        meter.$calorie.sink { (value) in
            self.calorie = String(format: "%0.1f", value)
        }
        .store(in: &cancellables)

        // 回転数
        meter.$count.sink { (value) in
            self.cycle = String(format: "%d", Int(value))
        }
        .store(in: &cancellables)

        // 顔の傾き
        FaceTracking.shared.$roll
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true).sink { (value) in
            self.face = String(format: "%0.4f", value)

            // rollが0以外の場合は左右に方向移動
            if value < 0 {
                self.webViewModel.evalute(javaScript: "right();")
            } else if 0 < value {
                self.webViewModel.evalute(javaScript: "left();")
            }
        }
        .store(in: &cancellables)

        // エアロバイクからの回転通知
        BLEClient.shared.$model.sink { (model) in
            guard let model = model else { return }

            if let _ = model.delta {
                // 移動
                meter.count += 1.0
                self.webViewModel.evalute(javaScript: "move();")
            }
        }
        .store(in: &cancellables)
    }

    /// Jumpボタン押下時の処理
    func jump() {
        self.webViewModel.evalute(javaScript: "jump();")
    }

}
