//
//  CycleMeter.swift
//  VirtualCycling
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Combine
import Foundation

/// サイクルメーター
class CycleMeter: ObservableObject {

    /// 1回転あたりの距離
    static let perDistance = 0.006

    /// 1回転あたりの消費カロリー
    static let perCalorie = 0.12

    /// 経過時間
    @Published var duration = 0.0;

    /// 距離
    @Published var distance = 0.0;

    /// 消費カロリー
    @Published var calorie = 0.0;

    /// 回転数
    @Published var count = 0.0;

    /// アイドル時間
    private var iduleDuration = 3000.0

    /// 毎秒呼ばれるタイマー
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    /// Combineのキャンセル
    private var cancellables = [AnyCancellable]()

    /// 初期化
    init() {
        timer.sink { [weak self] _ in
            guard let self = self else { return }

            if self.iduleDuration < 3000 {
                // アイドル時間が3秒以内なら継続と判定、経過時間を加算
                self.duration += 1000
            }

            self.iduleDuration += 1000
        }
        .store(in: &cancellables)

        $count.dropFirst().sink { [weak self] value in
            guard let self = self else { return }

            // アイドル時間をリセット
            self.iduleDuration = 0

            // 距離と消費カロリーを加算
            self.distance += CycleMeter.perDistance
            self.calorie += CycleMeter.perCalorie
        }
        .store(in: &cancellables)
    }

}
