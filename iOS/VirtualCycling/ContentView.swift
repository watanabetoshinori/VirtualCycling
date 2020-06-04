//
//  ContentView.swift
//  VirtualCycling
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import SwiftUI

/// コンテンツビュー
struct ContentView: View {

    /// 各種情報表示. 距離や消費カロリーなどを非表示にする場合は false
    @State var showInfo = true

    /// ビューモデル
    @ObservedObject var viewModel: ContentViewModel

    /// 各種情報表示
    var info: some View {
        GeometryReader { proxy in
            VStack () {
                Text(self.viewModel.time)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(self.viewModel.distance)
                        .foregroundColor(.white)
                        .frame(width: 40, alignment: .trailing)

                    Text("km")
                        .foregroundColor(.white)
                        .frame(width: 40, alignment: .leading)
                }

                HStack(spacing: 8) {
                    Text(self.viewModel.calorie)
                        .foregroundColor(.white)
                        .frame(width: 40, alignment: .trailing)

                    Text("cal")
                        .foregroundColor(.white)
                        .frame(width: 40, alignment: .leading)
                }

                HStack(spacing: 8) {
                    Text(self.viewModel.cycle)
                        .foregroundColor(.white)
                        .frame(width: 40, alignment: .trailing)

                    Text("cycle")
                        .foregroundColor(.white)
                        .frame(width: 40, alignment: .leading)
                }

                Text(self.viewModel.face)
                    .foregroundColor(.white)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            .offset(x: 16, y: 16)
        }
        .opacity(showInfo ? 1 : 0)
    }

    /// ジャンプボタン
    var jumpButton: some View {
        GeometryReader { proxy in
            Button(action: self.viewModel.jump) {
                Image(systemName: "arrow.right.arrow.left.circle")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottomLeading)
            .offset(x: 16, y: -26)
        }
        .opacity(showInfo ? 1 : 0)
    }

    var body: some View {
        // iPad Proの解像度でストリートビューにリクエストを出し続けると数回のリクエストでエラーになるため
        // 600x420をベースに拡大表示する
        GeometryReader { proxy in
            WebView(viewModel: self.viewModel.webViewModel)
                .frame(width: 600, height: 420)
                .transformEffect(CGAffineTransform(scaleX: (proxy.size.width / 600), y: (proxy.size.height / 420)))
                .overlay(self.info)
                .overlay(self.jumpButton)
                .offset(CGSize(width: -1 * ((proxy.size.width - 600) / 2), height: -1 * ((proxy.size.height - 420) / 2)))
        }
    }

    // MARK: - テキスト入力パネル

    private func showInputTextPanel(_ panel: InputTextPanel?) {
        guard let panel = panel else {
            return
        }

        // 入力フィールド付きのアラートはSwiftUIでは非対応のため
        // 従来通りUIAlertControllerを使用する

        let alertController = UIAlertController(title: panel.message, message: nil, preferredStyle: .alert)

        panel.items.forEach { item in
            alertController.addTextField { (textField) in
                textField.placeholder = item.placeholder
                textField.isSecureTextEntry = item.isSecure
            }
        }

        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { action in
            let values = alertController.textFields?.map { $0.text ?? "" }
            panel.handler(values)
        }))

        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: { action in
            panel.handler(nil)
        }))

        mostFrontViewController().present(alertController, animated: true, completion: nil)
    }

    private func mostFrontViewController() -> UIViewController {
        // 最前面にあるViewControllerを探す
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first ?? UIApplication.shared.keyWindow!
        var viewController = keyWindow.rootViewController!
        while(viewController.presentedViewController != nil) {
            viewController = viewController.presentedViewController!
        }
        return viewController
    }

}

// MARK: - プレビュー

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init(meter: CycleMeter(), webViewModel: WebViewModel()))
    }
}
