//
//  WebViewModel.swift
//  VirtualCycling
//
//  Created by Watanabe Toshinori on 2020/05/30.
//  Copyright © 2020 Watanabe Toshinori. All rights reserved.
//

import Combine
import WebKit

/// WebViewのモデル
class WebViewModel: ObservableObject {

    @Published var webView = WKWebView()

    @Published var showActivity = false

    @Published var prgress: Float = 0

    @Published var panel: Panel?

    @Published var inputTextPanel: InputTextPanel?

    private var observers = [NSKeyValueObservation]()

    /// 初期化
    public init() {
        observeWebViewStates(\.estimatedProgress)
        observeWebViewStates(\.title)
        observeWebViewStates(\.url)
        observeWebViewStates(\.canGoBack)
        observeWebViewStates(\.canGoForward)
    }

    /// KVO
    private func observeWebViewStates<Value>(_ keyPath: KeyPath<WKWebView, Value>) {
        observers.append(webView.observe(keyPath, options: .prior) { (_, _) in
            self.objectWillChange.send()
        })
    }

    /// JavaScriptを実行する
    func evalute(javaScript: String) {
        webView.evaluateJavaScript(javaScript) { (response, error) in
            if let error = error {
                print(error)
                return
            }
        }
    }

}
