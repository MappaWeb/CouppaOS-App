import Flutter
import SwiftUI
import UIKit

public class GlassBottomNavigationPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "glass_bottom_navigation",
      binaryMessenger: registrar.messenger()
    )
    let instance = GlassBottomNavigationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.register(
      NativeGlassButtonFactory(messenger: registrar.messenger()),
      withId: "glass_bottom_navigation/native_glass_button"
    )
    registrar.register(
      NativeGlassBarFactory(messenger: registrar.messenger()),
      withId: "glass_bottom_navigation/native_glass_bar"
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isLiquidGlassSupported":
      if #available(iOS 26.0, *) {
        result(true)
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

private final class NativeGlassButtonFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeGlassButtonView(
      frame: frame,
      viewId: viewId,
      arguments: args,
      messenger: messenger
    )
  }
}

private final class NativeGlassButtonView: NSObject, FlutterPlatformView {
  private let host: UIHostingController<AnyView>
  private let channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewId: Int64,
    arguments args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    let methodChannel = FlutterMethodChannel(
      name: "glass_bottom_navigation/native_glass_button_\(viewId)",
      binaryMessenger: messenger
    )
    channel = methodChannel

    let params = args as? [String: Any]
    let symbol = params?["symbolName"] as? String ?? symbolName(for: params?["icon"] as? String)
    let style = params?["style"] as? String
    let accessibilityLabel = params?["label"] as? String
    let size = (params?["size"] as? NSNumber)?.doubleValue ?? Double(frame.width)

    let root = NativeGlassIconButtonView(
      symbolName: symbol,
      style: style,
      size: size,
      onTap: {
        methodChannel.invokeMethod("tap", arguments: nil)
      }
    )
    host = UIHostingController(rootView: AnyView(root))
    super.init()
    host.view.backgroundColor = .clear
    // Prevent the screen's safe-area insets (notch/home indicator) from being
    // applied to this small embedded SwiftUI view, which otherwise offsets and
    // shrinks its content.
    if #available(iOS 16.4, *) {
      host.safeAreaRegions = []
    }
    host.view.frame = frame
    host.view.isAccessibilityElement = true
    host.view.accessibilityTraits = .button
    host.view.accessibilityLabel = accessibilityLabel
  }

  func view() -> UIView {
    host.view
  }
}

private struct NativeGlassIconButtonView: View {
  let symbolName: String
  let style: String?
  let size: Double
  let onTap: () -> Void

  var body: some View {
    if #available(iOS 26.0, *) {
      Button(action: onTap) {
        Image(systemName: symbolName)
          .font(.system(size: size * 0.4, weight: .regular))
          .foregroundColor(.primary)
          .frame(width: size, height: size)
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
      .glassEffect(.regular.interactive(), in: .circle)
    } else {
      Button(action: onTap) {
        Image(systemName: symbolName)
          .font(.system(size: size * 0.4, weight: .regular))
          .foregroundColor(.primary)
          .frame(width: size, height: size)
          .contentShape(Circle())
      }
      .buttonStyle(.plain)
      .background(
        Circle().fill(Color.white.opacity(0.16))
      )
    }
  }
}

private final class NativeGlassBarFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    NativeGlassBarView(
      frame: frame,
      viewId: viewId,
      arguments: args,
      messenger: messenger
    )
  }
}

private final class NativeGlassBarView: NSObject, FlutterPlatformView {
  private let rootView: UIView
  private let tabBar: UITabBar
  private let channel: FlutterMethodChannel
  private var items: [[String: Any]] = []
  private var currentIndex = 0
  private var accentColor = UIColor.systemPink
  private var iconPointSize: CGFloat = 22
  private var iconWeight: UIImage.SymbolWeight = .semibold

  init(
    frame: CGRect,
    viewId: Int64,
    arguments args: Any?,
    messenger: FlutterBinaryMessenger
  ) {
    rootView = UIView(frame: frame)
    tabBar = UITabBar(frame: frame)
    channel = FlutterMethodChannel(
      name: "glass_bottom_navigation/native_glass_bar_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    setupViews()
    apply(arguments: args)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else {
        result(nil)
        return
      }
      switch call.method {
      case "update":
        self.apply(arguments: call.arguments)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  func view() -> UIView {
    rootView
  }

  private func apply(arguments args: Any?) {
    let params = args as? [String: Any]
    items = params?["items"] as? [[String: Any]] ?? items
    currentIndex = params?["currentIndex"] as? Int ?? currentIndex
    if let accent = params?["accent"] as? Int {
      accentColor = color(fromARGB: accent)
    }
    if let pointSize = (params?["iconPointSize"] as? NSNumber)?.doubleValue {
      iconPointSize = CGFloat(pointSize)
    }
    if let weight = params?["iconWeight"] as? String {
      iconWeight = symbolWeight(from: weight)
    }
    renderButtons()
  }

  private func symbolWeight(from name: String) -> UIImage.SymbolWeight {
    switch name {
    case "ultraLight": return .ultraLight
    case "thin": return .thin
    case "light": return .light
    case "regular": return .regular
    case "medium": return .medium
    case "semibold": return .semibold
    case "bold": return .bold
    case "heavy": return .heavy
    case "black": return .black
    default: return .regular
    }
  }

  private func setupViews() {
    rootView.backgroundColor = .clear
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    tabBar.delegate = self
    tabBar.isTranslucent = true
    tabBar.tintColor = accentColor
    tabBar.unselectedItemTintColor = .label
    tabBar.itemPositioning = .fill
    rootView.addSubview(tabBar)

    if #available(iOS 26.0, *) {
      // On iOS 26 the system renders the tab bar with native Liquid Glass.
      // Keep the default appearance so the glass material is preserved and
      // do not clear the background/shadow images (doing so removes the glass).
      let appearance = UITabBarAppearance()
      appearance.configureWithDefaultBackground()
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
    } else if #available(iOS 15.0, *) {
      tabBar.backgroundImage = UIImage()
      tabBar.shadowImage = UIImage()
      let appearance = UITabBarAppearance()
      appearance.configureWithDefaultBackground()
      appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
      appearance.shadowColor = .clear
      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
    } else {
      tabBar.backgroundImage = UIImage()
      tabBar.shadowImage = UIImage()
    }

    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: rootView.trailingAnchor),
      tabBar.topAnchor.constraint(equalTo: rootView.topAnchor),
      tabBar.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
    ])
  }

  private func renderButtons() {
    tabBar.tintColor = accentColor
    let tabItems = items.enumerated().map { index, item in
      let title = item["label"] as? String
      let symbol = item["symbolName"] as? String
      let symbolConfig = UIImage.SymbolConfiguration(pointSize: iconPointSize, weight: iconWeight)
      let image = UIImage(systemName: symbol ?? "circle")?.withConfiguration(symbolConfig)
      let tabItem = UITabBarItem(
        title: title,
        image: image,
        selectedImage: image
      )
      tabItem.tag = index
      tabItem.imageInsets = UIEdgeInsets(top: -8, left: 0, bottom: 8, right: 0)
      tabItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 8)
      tabItem.setTitleTextAttributes(
        [.font: UIFont.systemFont(ofSize: 13, weight: .medium)],
        for: .normal
      )
      tabItem.setTitleTextAttributes(
        [.font: UIFont.systemFont(ofSize: 13, weight: .semibold)],
        for: .selected
      )
      return tabItem
    }
    tabBar.items = tabItems
    if tabItems.indices.contains(currentIndex) {
      tabBar.selectedItem = tabItems[currentIndex]
    }
  }
}

extension NativeGlassBarView: UITabBarDelegate {
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    currentIndex = item.tag
    channel.invokeMethod("tap", arguments: item.tag)
  }
}

private func symbolName(for icon: String?) -> String {
  switch icon {
  case "back":
    return "chevron.backward"
  case "close":
    return "xmark"
  case "search":
    return "magnifyingglass"
  case "more":
    return "ellipsis"
  case "add":
    return "plus"
  case "settings":
    return "gearshape"
  case "favorite":
    return "heart"
  case "share":
    return "square.and.arrow.up"
  default:
    return "circle"
  }
}

private func color(fromARGB value: Int) -> UIColor {
  let alpha = CGFloat((value >> 24) & 0xff) / 255.0
  let red = CGFloat((value >> 16) & 0xff) / 255.0
  let green = CGFloat((value >> 8) & 0xff) / 255.0
  let blue = CGFloat(value & 0xff) / 255.0
  return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}
