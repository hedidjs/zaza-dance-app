Last login: Sun Aug 17 22:42:12 on ttys000
You have mail.
rontzarfati@ron zaza % flutter analyze
Analyzing zaza...                                                       

   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/settings/presentation/pages/general_settings_page.dart:84
          3:42 • use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/settings/presentation/pages/general_settings_page.dart:85
          5:42 • use_build_context_synchronously
   info • 'groupValue' is deprecated and shouldn't be used. Use a RadioGroup
          ancestor to manage group value instead. This feature was deprecated
          after v3.32.0-0.0.pre •
          lib/features/settings/presentation/pages/notification_settings_page.da
          rt:554:15 • deprecated_member_use
   info • 'onChanged' is deprecated and shouldn't be used. Use RadioGroup to
          handle value change instead. This feature was deprecated after
          v3.32.0-0.0.pre •
          lib/features/settings/presentation/pages/notification_settings_page.da
          rt:555:15 • deprecated_member_use
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/settings/presentation/pages/notification_settings_page.da
          rt:759:42 • use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/settings/presentation/pages/notification_settings_page.da
          rt:772:42 • use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/settings/presentation/pages/profile_settings_page.dart:80
          0:42 • use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps, guarded by an unrelated
          'mounted' check •
          lib/features/settings/presentation/pages/profile_settings_page.dart:81
          3:42 • use_build_context_synchronously

8 issues found. (ran in 2.6s)
rontzarfati@ron zaza % Flutter Inspector
Error! Executable name Flutter not recognized!
rontzarfati@ron zaza % flutter run
Launching lib/main.dart on SM G973F in debug mode...
Running Gradle task 'assembleDebug'...                             18.7s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app-debug.apk...           6.7s
D/FlutterJNI(21250): Beginning load of flutter...
D/FlutterJNI(21250): flutter (null) was loaded normally!
I/flutter (21250): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
Syncing files to device SM G973F...                                156ms

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on SM G973F is available at:
http://127.0.0.1:49894/ITEeBI65r_0=/
The Flutter DevTools debugger and profiler on SM G973F is available at:
http://127.0.0.1:9100?uri=http://127.0.0.1:49894/ITEeBI65r_0=/
I/Choreographer(21250): Skipped 84 frames!  The application may be doing too much work on its main thread.
I/SurfaceView@b938322(21250): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ......I. 0,0-0,0} of ViewRootImpl@6e2975d[MainActivity]
I/ViewRootImpl@6e2975d[MainActivity](21250): Relayout returned: old=(0,0,1080,2280) new=(0,0,1080,2280) req=(1080,2280)0 dur=5 res=0x7 s={true 539086329776} ch=true fn=-1
D/hw-ProcessState(21250): Binder ioctl to enable oneway spam detection failed: Invalid argument
D/OpenGLRenderer(21250): eglCreateWindowSurface
I/SurfaceView@b938322(21250): windowStopped(false) true io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ......ID 0,0-1080,2154} of ViewRootImpl@6e2975d[MainActivity]
I/ViewRootImpl@6e2975d[MainActivity](21250): [DP] dp(1) 1 android.view.ViewRootImpl.reportNextDraw:11442 android.view.ViewRootImpl.performTraversals:4198 android.view.ViewRootImpl.doTraversal:2924 
I/SurfaceView@b938322(21250): pST: sr = Rect(0, 0 - 1080, 2154) sw = 1080 sh = 2154
I/SurfaceView@b938322(21250): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@b938322(21250): pST: mTmpTransaction.apply, mTmpTransaction = android.view.SurfaceControl$Transaction@cea9d01
I/SurfaceView@b938322(21250): updateSurface: mVisible = true mSurface.isValid() = true
I/SurfaceView@b938322(21250): updateSurface: mSurfaceCreated = false surfaceChanged = true visibleChanged = true
I/SurfaceView@b938322(21250): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ......ID 0,0-1080,2154}
I/BufferQueueProducer(21250): [SurfaceView - com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity@b938322@0#1(BLAST Consumer)1](id:530200000001,api:1,p:21250,c:21250) FrameBooster: VULKAN surface was catched
D/ance.zaza_danc(21250): FrameBooster: InterpolationGui: UID 10328 detected as using Vulkan
I/Gralloc4(21250): mapper 4.x is not supported
W/Gralloc3(21250): mapper 3.x is not supported
I/gralloc (21250): Arm Module v1.0
W/Gralloc4(21250): allocator 4.x is not supported
W/Gralloc3(21250): allocator 3.x is not supported
I/SurfaceView@b938322(21250): surfaceChanged (1080,2154) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ......ID 0,0-1080,2154}
I/ViewRootImpl@6e2975d[MainActivity](21250): [DP] dp(2) 1 android.view.SurfaceView.updateSurface:1375 android.view.SurfaceView.lambda$new$1$SurfaceView:254 android.view.SurfaceView$$ExternalSyntheticLambda2.onPreDraw:2 
I/ViewRootImpl@6e2975d[MainActivity](21250): [DP] pdf(1) 1 android.view.SurfaceView.notifyDrawFinished:599 android.view.SurfaceView.performDrawFinished:586 android.view.SurfaceView.$r8$lambda$st27mCkd9jfJkTrN_P3qIGKX6NY:0 
D/ViewRootImpl@6e2975d[MainActivity](21250): pendingDrawFinished. Waiting on draw reported mDrawsNeededToReport=1
D/ViewRootImpl@6e2975d[MainActivity](21250): Creating frameDrawingCallback nextDrawUseBlastSync=false reportNextDraw=true hasBlurUpdates=false
D/ViewRootImpl@6e2975d[MainActivity](21250): Creating frameCompleteCallback
I/SurfaceView@b938322(21250): uSP: rtp = Rect(0, 0 - 1080, 2154) rtsw = 1080 rtsh = 2154
I/SurfaceView@b938322(21250): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@b938322(21250): aOrMT: uB = true t = android.view.SurfaceControl$Transaction@b8157a6 fN = 1 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1728 android.graphics.RenderNode$CompositePositionUpdateListener.positionChanged:319 
I/SurfaceView@b938322(21250): aOrMT: vR.mWNT, vR = ViewRootImpl@6e2975d[MainActivity]
I/ViewRootImpl@6e2975d[MainActivity](21250): mWNT: t = android.view.SurfaceControl$Transaction@b8157a6 fN = 1 android.view.SurfaceView.applyOrMergeTransaction:1628 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1728 
I/ViewRootImpl@6e2975d[MainActivity](21250): mWNT: merge t to BBQ
D/ViewRootImpl@6e2975d[MainActivity](21250): Received frameDrawingCallback frameNum=1. Creating transactionCompleteCallback=false
D/ViewRootImpl@6e2975d[MainActivity](21250): Received frameCompleteCallback  lastAcquiredFrameNum=1 lastAttemptedDrawFrameNum=1
I/ViewRootImpl@6e2975d[MainActivity](21250): [DP] pdf(0) 1 android.view.ViewRootImpl.lambda$addFrameCompleteCallbackIfNeeded$3$ViewRootImpl:5000 android.view.ViewRootImpl$$ExternalSyntheticLambda16.run:6 android.os.Handler.handleCallback:938 
I/ViewRootImpl@6e2975d[MainActivity](21250): [DP] rdf()
D/ViewRootImpl@6e2975d[MainActivity](21250): reportDrawFinished (fn: -1) 
I/flutter (21250): Deep Link Service initialized
D/InsetsSourceConsumer(21250): ensureControlAlpha: for ITYPE_NAVIGATION_BAR on com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity
D/InsetsSourceConsumer(21250): ensureControlAlpha: for ITYPE_STATUS_BAR on com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity
I/flutter (21250): PushNotificationService initialized successfully
I/ViewRootImpl@6e2975d[MainActivity](21250): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(21250): startInputInner - Id : 0
I/InputMethodManager(21250): startInputInner - mService.startInputOrWindowGainedFocus
D/InputMethodManager(21250): startInputInner - Id : 0
D/ProfileInstaller(21250): Installing profile for com.zazadance.zaza_dance

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY
╞═══════════════════════════════════════════════════════════
The following _TypeError was thrown building ProfilePage(dirty, dependencies:
[UncontrolledProviderScope], state: _ConsumerState#b8b67):
type 'UserRole' is not a subtype of type 'String'

The relevant error-causing widget was:
  ProfilePage
  ProfilePage:file:///Users/rontzarfati/Desktop/zaza/lib/main.dart:105:46

When the exception was thrown, this was the stack:
#0      ProfilePage._buildProfileHeader
(package:zaza_dance/features/profile/presentation/pages/profile_page.dart:126:42
)
#1      ProfilePage._buildContent
(package:zaza_dance/features/profile/presentation/pages/profile_page.dart:85:11)
#2      ProfilePage.build.<anonymous closure>
(package:zaza_dance/features/profile/presentation/pages/profile_page.dart:58:31)
#3      AsyncValueX.when (package:riverpod/src/common.dart:742:16)
#4      ProfilePage.build
(package:zaza_dance/features/profile/presentation/pages/profile_page.dart:57:32)
#5      _ConsumerState.build (package:flutter_riverpod/src/consumer.dart:476:19)
#6      StatefulElement.build
(package:flutter/src/widgets/framework.dart:5833:27)
#7      ConsumerStatefulElement.build
(package:flutter_riverpod/src/consumer.dart:539:20)
#8      ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5723:15)
#9      StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#10     Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#11     ComponentElement._firstBuild
(package:flutter/src/widgets/framework.dart:5705:5)
#12     StatefulElement._firstBuild
(package:flutter/src/widgets/framework.dart:5875:11)
#13     ComponentElement.mount
(package:flutter/src/widgets/framework.dart:5699:5)
...     Normal element mounting (234 frames)
#247    Element.inflateWidget
(package:flutter/src/widgets/framework.dart:4548:16)
#248    MultiChildRenderObjectElement.inflateWidget
(package:flutter/src/widgets/framework.dart:7169:36)
#249    Element.updateChild (package:flutter/src/widgets/framework.dart:4004:18)
#250    Element.updateChildren
(package:flutter/src/widgets/framework.dart:4203:32)
#251    MultiChildRenderObjectElement.update
(package:flutter/src/widgets/framework.dart:7202:17)
#252    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#253    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#254    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#255    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#256    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#257    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#258    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#259    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#260    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#261    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#262    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#263    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#264    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#265    _InheritedNotifierElement.update
(package:flutter/src/widgets/inherited_notifier.dart:108:11)
#266    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#267    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#268    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#269    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#270    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#271    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#272    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#273    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#274    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#275    _InheritedNotifierElement.update
(package:flutter/src/widgets/inherited_notifier.dart:108:11)
#276    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#277    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#278    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#279    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#280    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#281    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#282    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#283    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#284    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#285    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#286    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#287    SingleChildRenderObjectElement.update
(package:flutter/src/widgets/framework.dart:7025:14)
#288    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#289    SingleChildRenderObjectElement.update
(package:flutter/src/widgets/framework.dart:7025:14)
#290    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#291    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#292    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#293    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#294    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#295    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#296    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#297    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#298    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#299    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#300    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#301    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#302    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#303    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#304    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#305    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#306    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#307    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#308    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#309    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#310    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#311    _InheritedNotifierElement.update
(package:flutter/src/widgets/inherited_notifier.dart:108:11)
#312    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#313    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#314    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#315    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#316    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#317    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#318    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#319    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#320    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#321    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#322    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#323    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#324    StatelessElement.update
(package:flutter/src/widgets/framework.dart:5797:5)
#325    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#326    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#327    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#328    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#329    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#330    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#331    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#332    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#333    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#334    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#335    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#336    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#337    BuildScope._tryRebuild
(package:flutter/src/widgets/framework.dart:2695:15)
#338    BuildScope._flushDirtyElements
(package:flutter/src/widgets/framework.dart:2752:11)
#339    BuildOwner.buildScope
(package:flutter/src/widgets/framework.dart:3056:18)
#340    WidgetsBinding.drawFrame
(package:flutter/src/widgets/binding.dart:1259:21)
#341    RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:495:5)
#342    SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1434:15)
#343    SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1347:9)
#344    SchedulerBinding._handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1200:5)
#345    _invoke (dart:ui/hooks.dart:330:13)
#346    PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:444:5)
#347    _drawFrame (dart:ui/hooks.dart:302:31)

════════════════════════════════════════════════════════════════════════════════
════════════════════

I/ViewRootImpl@6e2975d[MainActivity](21250): ViewPostIme key 0
I/ViewRootImpl@6e2975d[MainActivity](21250): ViewPostIme key 1
I/ViewRootImpl@6e2975d[MainActivity](21250): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputTransport(21250): Input channel destroyed: 'ClientS', fd=140
I/ViewRootImpl@6e2975d[MainActivity](21250): handleAppVisibility mAppVisible=true visible=false
I/SurfaceView@b938322(21250): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ........ 0,0-1080,2154} of ViewRootImpl@6e2975d[MainActivity]
I/SurfaceView@b938322(21250): pST: mTmpTransaction.apply, mTmpTransaction = android.view.SurfaceControl$Transaction@cea9d01
I/SurfaceView@b938322(21250): surfaceDestroyed callback.size 1 #2 io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ........ 0,0-1080,2154}
I/SurfaceView@b938322(21250): updateSurface: mVisible = false mSurface.isValid() = true
I/SurfaceView@b938322(21250): tryReleaseSurfaces: set mRtReleaseSurfaces = true
I/SurfaceView@b938322(21250): 263091736 wPL, frameNr = 0
I/SurfaceView@b938322(21250): remove() from RT android.view.SurfaceView$SurfaceViewPositionUpdateListener@fae7618 Surface(name=SurfaceView - com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity@b938322@0)/@0x3d3c871
I/SurfaceView@b938322(21250): remove() io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ........ 0,0-1080,2154} Surface(name=SurfaceView - com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity@b938322@0)/@0x3d3c871
I/SurfaceView@b938322(21250): aOrMT: uB = true t = android.view.SurfaceControl$Transaction@220dbc4 fN = 0 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionLost:1785 android.graphics.RenderNode$CompositePositionUpdateListener.positionLost:326 
I/SurfaceView@b938322(21250): aOrMT: vR.mWNT, vR = ViewRootImpl@6e2975d[MainActivity]
I/ViewRootImpl@6e2975d[MainActivity](21250): mWNT: t = android.view.SurfaceControl$Transaction@220dbc4 fN = 0 android.view.SurfaceView.applyOrMergeTransaction:1628 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionLost:1785 
I/ViewRootImpl@6e2975d[MainActivity](21250): mWNT: merge t to BBQ
D/OpenGLRenderer(21250): setSurface called with nullptr
D/OpenGLRenderer(21250): setSurface() destroyed EGLSurface
D/OpenGLRenderer(21250): destroyEglSurface
I/ViewRootImpl@6e2975d[MainActivity](21250): Relayout returned: old=(0,0,1080,2280) new=(0,0,1080,2280) req=(1080,2280)8 dur=4 res=0x5 s={false 0} ch=true fn=4
I/SurfaceView@b938322(21250): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{b938322 V.E...... ........ 0,0-1080,2154} of ViewRootImpl@6e2975d[MainActivity]
D/SurfaceView@b938322(21250): updateSurface: surface is not valid
D/SurfaceView@b938322(21250): updateSurface: surface is not valid
I/ViewRootImpl@6e2975d[MainActivity](21250): stopped(true) old=false
D/SurfaceView@b938322(21250): updateSurface: surface is not valid
D/SurfaceView@b938322(21250): updateSurface: surface is not valid
I/SurfaceView@b938322(21250): onDetachedFromWindow: tryReleaseSurfaces()
D/OpenGLRenderer(21250): setSurface called with nullptr
I/ViewRootImpl@6e2975d[MainActivity](21250): dispatchDetachedFromWindow
D/InputTransport(21250): Input channel destroyed: 'a5b8f8a', fd=103
I/flutter (21250): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
D/com.llfbandit.app_links(21250): Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=com.zazadance.zaza_dance/.MainActivity bnds=[291,159][537,490] }
I/DecorView(21250): [INFO] isPopOver=false, config=true
I/DecorView(21250): updateCaptionType >> DecorView@df5e5bb[], isFloating=false, isApplication=true, hasWindowControllerCallback=true, hasWindowDecorCaption=false
D/DecorView(21250): setCaptionType = 0, this = DecorView@df5e5bb[]
I/DecorView(21250): getCurrentDensityDpi: from real metrics. densityDpi=420 msg=resources_loaded
I/DecorView(21250): notifyKeepScreenOnChanged: keepScreenOn=false
I/ViewRootImpl@45d5133[MainActivity](21250): setView = com.android.internal.policy.DecorView@df5e5bb TM=true
I/Choreographer(21250): Skipped 80 frames!  The application may be doing too much work on its main thread.
I/SurfaceView@53373c0(21250): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ......I. 0,0-0,0} of ViewRootImpl@45d5133[MainActivity]
I/ViewRootImpl@45d5133[MainActivity](21250): Relayout returned: old=(0,0,1080,2280) new=(0,0,1080,2280) req=(1080,2280)0 dur=6 res=0x7 s={true 539086870416} ch=true fn=-1
D/OpenGLRenderer(21250): eglCreateWindowSurface
I/SurfaceView@53373c0(21250): windowStopped(false) true io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ......ID 0,0-1080,2154} of ViewRootImpl@45d5133[MainActivity]
I/ViewRootImpl@45d5133[MainActivity](21250): [DP] dp(1) 1 android.view.ViewRootImpl.reportNextDraw:11442 android.view.ViewRootImpl.performTraversals:4198 android.view.ViewRootImpl.doTraversal:2924 
I/SurfaceView@53373c0(21250): pST: sr = Rect(0, 0 - 1080, 2154) sw = 1080 sh = 2154
I/SurfaceView@53373c0(21250): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@53373c0(21250): pST: mTmpTransaction.apply, mTmpTransaction = android.view.SurfaceControl$Transaction@d11cd8f
I/SurfaceView@53373c0(21250): updateSurface: mVisible = true mSurface.isValid() = true
I/SurfaceView@53373c0(21250): updateSurface: mSurfaceCreated = false surfaceChanged = true visibleChanged = true
I/SurfaceView@53373c0(21250): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ......ID 0,0-1080,2154}
I/BufferQueueProducer(21250): [SurfaceView - com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity@53373c0@0#3(BLAST Consumer)3](id:530200000003,api:1,p:21250,c:21250) FrameBooster: VULKAN surface was catched
D/ance.zaza_danc(21250): FrameBooster: InterpolationGui: UID 10328 detected as using Vulkan
I/SurfaceView@53373c0(21250): surfaceChanged (1080,2154) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ......ID 0,0-1080,2154}
I/ViewRootImpl@45d5133[MainActivity](21250): [DP] dp(2) 1 android.view.SurfaceView.updateSurface:1375 android.view.SurfaceView.lambda$new$1$SurfaceView:254 android.view.SurfaceView$$ExternalSyntheticLambda2.onPreDraw:2 
I/ViewRootImpl@45d5133[MainActivity](21250): [DP] pdf(1) 1 android.view.SurfaceView.notifyDrawFinished:599 android.view.SurfaceView.performDrawFinished:586 android.view.SurfaceView.$r8$lambda$st27mCkd9jfJkTrN_P3qIGKX6NY:0 
D/ViewRootImpl@45d5133[MainActivity](21250): pendingDrawFinished. Waiting on draw reported mDrawsNeededToReport=1
I/flutter (21250): Deep Link Service initialized
D/ViewRootImpl@45d5133[MainActivity](21250): Creating frameDrawingCallback nextDrawUseBlastSync=false reportNextDraw=true hasBlurUpdates=false
D/ViewRootImpl@45d5133[MainActivity](21250): Creating frameCompleteCallback
I/SurfaceView@53373c0(21250): uSP: rtp = Rect(0, 0 - 1080, 2154) rtsw = 1080 rtsh = 2154
I/SurfaceView@53373c0(21250): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@53373c0(21250): aOrMT: uB = true t = android.view.SurfaceControl$Transaction@8d0481c fN = 1 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1728 android.graphics.RenderNode$CompositePositionUpdateListener.positionChanged:319 
I/SurfaceView@53373c0(21250): aOrMT: vR.mWNT, vR = ViewRootImpl@45d5133[MainActivity]
I/ViewRootImpl@45d5133[MainActivity](21250): mWNT: t = android.view.SurfaceControl$Transaction@8d0481c fN = 1 android.view.SurfaceView.applyOrMergeTransaction:1628 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1728 
I/ViewRootImpl@45d5133[MainActivity](21250): mWNT: merge t to BBQ
D/ViewRootImpl@45d5133[MainActivity](21250): Received frameDrawingCallback frameNum=1. Creating transactionCompleteCallback=false
D/ViewRootImpl@45d5133[MainActivity](21250): Received frameCompleteCallback  lastAcquiredFrameNum=1 lastAttemptedDrawFrameNum=1
I/ViewRootImpl@45d5133[MainActivity](21250): [DP] pdf(0) 1 android.view.ViewRootImpl.lambda$addFrameCompleteCallbackIfNeeded$3$ViewRootImpl:5000 android.view.ViewRootImpl$$ExternalSyntheticLambda16.run:6 android.os.Handler.handleCallback:938 
I/ViewRootImpl@45d5133[MainActivity](21250): [DP] rdf()
D/ViewRootImpl@45d5133[MainActivity](21250): reportDrawFinished (fn: -1) 
D/InsetsSourceConsumer(21250): ensureControlAlpha: for ITYPE_NAVIGATION_BAR on com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity
D/InsetsSourceConsumer(21250): ensureControlAlpha: for ITYPE_STATUS_BAR on com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity
I/flutter (21250): PushNotificationService initialized successfully
I/ViewRootImpl@45d5133[MainActivity](21250): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(21250): startInputInner - Id : 0
I/InputMethodManager(21250): startInputInner - mService.startInputOrWindowGainedFocus

══╡ EXCEPTION CAUGHT BY WIDGETS LIBRARY
╞═══════════════════════════════════════════════════════════
The following _TypeError was thrown building SettingsPage(dirty, dependencies:
[UncontrolledProviderScope], state: _ConsumerState#6cc75):
type 'UserRole' is not a subtype of type 'String'

The relevant error-causing widget was:
  SettingsPage
  SettingsPage:file:///Users/rontzarfati/Desktop/zaza/lib/main.dart:101:46

When the exception was thrown, this was the stack:
#0      SettingsPage._buildUserHeader.<anonymous closure>
(package:zaza_dance/features/settings/presentation/pages/settings_page.dart:232:
52)
#1      AsyncValueX.when (package:riverpod/src/common.dart:742:16)
#2      SettingsPage._buildUserHeader
(package:zaza_dance/features/settings/presentation/pages/settings_page.dart:161:
22)
#3      SettingsPage.build
(package:zaza_dance/features/settings/presentation/pages/settings_page.dart:54:2
1)
#4      _ConsumerState.build (package:flutter_riverpod/src/consumer.dart:476:19)
#5      StatefulElement.build
(package:flutter/src/widgets/framework.dart:5833:27)
#6      ConsumerStatefulElement.build
(package:flutter_riverpod/src/consumer.dart:539:20)
#7      ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5723:15)
#8      StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#9      Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#10     ComponentElement._firstBuild
(package:flutter/src/widgets/framework.dart:5705:5)
#11     StatefulElement._firstBuild
(package:flutter/src/widgets/framework.dart:5875:11)
#12     ComponentElement.mount
(package:flutter/src/widgets/framework.dart:5699:5)
...     Normal element mounting (234 frames)
#246    Element.inflateWidget
(package:flutter/src/widgets/framework.dart:4548:16)
#247    MultiChildRenderObjectElement.inflateWidget
(package:flutter/src/widgets/framework.dart:7169:36)
#248    Element.updateChild (package:flutter/src/widgets/framework.dart:4004:18)
#249    Element.updateChildren
(package:flutter/src/widgets/framework.dart:4203:32)
#250    MultiChildRenderObjectElement.update
(package:flutter/src/widgets/framework.dart:7202:17)
#251    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#252    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#253    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#254    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#255    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#256    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#257    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#258    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#259    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#260    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#261    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#262    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#263    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#264    _InheritedNotifierElement.update
(package:flutter/src/widgets/inherited_notifier.dart:108:11)
#265    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#266    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#267    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#268    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#269    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#270    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#271    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#272    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#273    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#274    _InheritedNotifierElement.update
(package:flutter/src/widgets/inherited_notifier.dart:108:11)
#275    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#276    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#277    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#278    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#279    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#280    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#281    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#282    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#283    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#284    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#285    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#286    SingleChildRenderObjectElement.update
(package:flutter/src/widgets/framework.dart:7025:14)
#287    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#288    SingleChildRenderObjectElement.update
(package:flutter/src/widgets/framework.dart:7025:14)
#289    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#290    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#291    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#292    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#293    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#294    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#295    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#296    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#297    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#298    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#299    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#300    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#301    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#302    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#303    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#304    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#305    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#306    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#307    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#308    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#309    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#310    _InheritedNotifierElement.update
(package:flutter/src/widgets/inherited_notifier.dart:108:11)
#311    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#312    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#313    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#314    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#315    StatefulElement.update
(package:flutter/src/widgets/framework.dart:5909:5)
#316    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#317    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#318    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#319    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#320    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#321    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#322    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#323    StatelessElement.update
(package:flutter/src/widgets/framework.dart:5797:5)
#324    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#325    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#326    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#327    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#328    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#329    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#330    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#331    ProxyElement.update (package:flutter/src/widgets/framework.dart:6051:5)
#332    Element.updateChild (package:flutter/src/widgets/framework.dart:3982:15)
#333    ComponentElement.performRebuild
(package:flutter/src/widgets/framework.dart:5747:16)
#334    StatefulElement.performRebuild
(package:flutter/src/widgets/framework.dart:5884:11)
#335    Element.rebuild (package:flutter/src/widgets/framework.dart:5435:7)
#336    BuildScope._tryRebuild
(package:flutter/src/widgets/framework.dart:2695:15)
#337    BuildScope._flushDirtyElements
(package:flutter/src/widgets/framework.dart:2752:11)
#338    BuildOwner.buildScope
(package:flutter/src/widgets/framework.dart:3056:18)
#339    WidgetsBinding.drawFrame
(package:flutter/src/widgets/binding.dart:1259:21)
#340    RendererBinding._handlePersistentFrameCallback
(package:flutter/src/rendering/binding.dart:495:5)
#341    SchedulerBinding._invokeFrameCallback
(package:flutter/src/scheduler/binding.dart:1434:15)
#342    SchedulerBinding.handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1347:9)
#343    SchedulerBinding._handleDrawFrame
(package:flutter/src/scheduler/binding.dart:1200:5)
#344    _invoke (dart:ui/hooks.dart:330:13)
#345    PlatformDispatcher._drawFrame (dart:ui/platform_dispatcher.dart:444:5)
#346    _drawFrame (dart:ui/hooks.dart:302:31)

════════════════════════════════════════════════════════════════════════════════
════════════════════

I/ViewRootImpl@45d5133[MainActivity](21250): ViewPostIme key 0
I/ViewRootImpl@45d5133[MainActivity](21250): ViewPostIme key 1
I/ViewRootImpl@45d5133[MainActivity](21250): MSG_WINDOW_FOCUS_CHANGED 0 1
D/InputTransport(21250): Input channel destroyed: 'ClientS', fd=143
I/ViewRootImpl@45d5133[MainActivity](21250): handleAppVisibility mAppVisible=true visible=false
I/SurfaceView@53373c0(21250): onWindowVisibilityChanged(8) false io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ........ 0,0-1080,2154} of ViewRootImpl@45d5133[MainActivity]
I/SurfaceView@53373c0(21250): pST: mTmpTransaction.apply, mTmpTransaction = android.view.SurfaceControl$Transaction@d11cd8f
I/SurfaceView@53373c0(21250): surfaceDestroyed callback.size 1 #2 io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ........ 0,0-1080,2154}
I/SurfaceView@53373c0(21250): updateSurface: mVisible = false mSurface.isValid() = true
I/SurfaceView@53373c0(21250): tryReleaseSurfaces: set mRtReleaseSurfaces = true
I/SurfaceView@53373c0(21250): 216511403 wPL, frameNr = 0
I/SurfaceView@53373c0(21250): remove() from RT android.view.SurfaceView$SurfaceViewPositionUpdateListener@ce7b3ab Surface(name=SurfaceView - com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity@53373c0@0)/@0x8a7ca08
I/SurfaceView@53373c0(21250): remove() io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ........ 0,0-1080,2154} Surface(name=SurfaceView - com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity@53373c0@0)/@0x8a7ca08
I/SurfaceView@53373c0(21250): aOrMT: uB = true t = android.view.SurfaceControl$Transaction@3ebdf87 fN = 0 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionLost:1785 android.graphics.RenderNode$CompositePositionUpdateListener.positionLost:326 
I/SurfaceView@53373c0(21250): aOrMT: vR.mWNT, vR = ViewRootImpl@45d5133[MainActivity]
I/ViewRootImpl@45d5133[MainActivity](21250): mWNT: t = android.view.SurfaceControl$Transaction@3ebdf87 fN = 0 android.view.SurfaceView.applyOrMergeTransaction:1628 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionLost:1785 
I/ViewRootImpl@45d5133[MainActivity](21250): mWNT: merge t to BBQ
D/OpenGLRenderer(21250): setSurface called with nullptr
D/OpenGLRenderer(21250): setSurface() destroyed EGLSurface
D/OpenGLRenderer(21250): destroyEglSurface
I/ViewRootImpl@45d5133[MainActivity](21250): Relayout returned: old=(0,0,1080,2280) new=(0,0,1080,2280) req=(1080,2280)8 dur=4 res=0x5 s={false 0} ch=true fn=2
I/SurfaceView@53373c0(21250): windowStopped(true) false io.flutter.embedding.android.FlutterSurfaceView{53373c0 V.E...... ........ 0,0-1080,2154} of ViewRootImpl@45d5133[MainActivity]
D/SurfaceView@53373c0(21250): updateSurface: surface is not valid
D/SurfaceView@53373c0(21250): updateSurface: surface is not valid
I/ViewRootImpl@45d5133[MainActivity](21250): stopped(true) old=false
D/SurfaceView@53373c0(21250): updateSurface: surface is not valid
D/SurfaceView@53373c0(21250): updateSurface: surface is not valid
I/SurfaceView@53373c0(21250): onDetachedFromWindow: tryReleaseSurfaces()
D/OpenGLRenderer(21250): setSurface called with nullptr
I/ViewRootImpl@45d5133[MainActivity](21250): dispatchDetachedFromWindow
D/InputTransport(21250): Input channel destroyed: '1b3a559', fd=111
I/flutter (21250): [IMPORTANT:flutter/shell/platform/android/android_context_vk_impeller.cc(62)] Using the Impeller rendering backend (Vulkan).
D/com.llfbandit.app_links(21250): Intent { act=android.intent.action.MAIN cat=[android.intent.category.LAUNCHER] flg=0x10200000 cmp=com.zazadance.zaza_dance/.MainActivity bnds=[291,159][537,490] }
I/DecorView(21250): [INFO] isPopOver=false, config=true
I/DecorView(21250): updateCaptionType >> DecorView@2e7b8ba[], isFloating=false, isApplication=true, hasWindowControllerCallback=true, hasWindowDecorCaption=false
D/DecorView(21250): setCaptionType = 0, this = DecorView@2e7b8ba[]
I/DecorView(21250): getCurrentDensityDpi: from real metrics. densityDpi=420 msg=resources_loaded
D/OpenGLRenderer(21250): setSurface called with nullptr
D/OpenGLRenderer(21250): setSurface called with nullptr
I/DecorView(21250): notifyKeepScreenOnChanged: keepScreenOn=false
I/ViewRootImpl@578a512[MainActivity](21250): setView = com.android.internal.policy.DecorView@2e7b8ba TM=true
I/Choreographer(21250): Skipped 80 frames!  The application may be doing too much work on its main thread.
I/SurfaceView@5e0e8f3(21250): onWindowVisibilityChanged(0) true io.flutter.embedding.android.FlutterSurfaceView{5e0e8f3 V.E...... ......I. 0,0-0,0} of ViewRootImpl@578a512[MainActivity]
I/ViewRootImpl@578a512[MainActivity](21250): Relayout returned: old=(0,0,1080,2280) new=(0,0,1080,2280) req=(1080,2280)0 dur=6 res=0x7 s={true 539086826816} ch=true fn=-1
D/OpenGLRenderer(21250): eglCreateWindowSurface
I/SurfaceView@5e0e8f3(21250): windowStopped(false) true io.flutter.embedding.android.FlutterSurfaceView{5e0e8f3 V.E...... ......ID 0,0-1080,2154} of ViewRootImpl@578a512[MainActivity]
I/ViewRootImpl@578a512[MainActivity](21250): [DP] dp(1) 1 android.view.ViewRootImpl.reportNextDraw:11442 android.view.ViewRootImpl.performTraversals:4198 android.view.ViewRootImpl.doTraversal:2924 
I/SurfaceView@5e0e8f3(21250): pST: sr = Rect(0, 0 - 1080, 2154) sw = 1080 sh = 2154
I/SurfaceView@5e0e8f3(21250): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@5e0e8f3(21250): pST: mTmpTransaction.apply, mTmpTransaction = android.view.SurfaceControl$Transaction@7b8005e
I/SurfaceView@5e0e8f3(21250): updateSurface: mVisible = true mSurface.isValid() = true
I/SurfaceView@5e0e8f3(21250): updateSurface: mSurfaceCreated = false surfaceChanged = true visibleChanged = true
I/SurfaceView@5e0e8f3(21250): surfaceCreated 1 #8 io.flutter.embedding.android.FlutterSurfaceView{5e0e8f3 V.E...... ......ID 0,0-1080,2154}
I/BufferQueueProducer(21250): [SurfaceView - com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity@5e0e8f3@0#5(BLAST Consumer)5](id:530200000005,api:1,p:21250,c:21250) FrameBooster: VULKAN surface was catched
D/ance.zaza_danc(21250): FrameBooster: InterpolationGui: UID 10328 detected as using Vulkan
I/SurfaceView@5e0e8f3(21250): surfaceChanged (1080,2154) 1 #8 io.flutter.embedding.android.FlutterSurfaceView{5e0e8f3 V.E...... ......ID 0,0-1080,2154}
I/ViewRootImpl@578a512[MainActivity](21250): [DP] dp(2) 1 android.view.SurfaceView.updateSurface:1375 android.view.SurfaceView.lambda$new$1$SurfaceView:254 android.view.SurfaceView$$ExternalSyntheticLambda2.onPreDraw:2 
I/ViewRootImpl@578a512[MainActivity](21250): [DP] pdf(1) 1 android.view.SurfaceView.notifyDrawFinished:599 android.view.SurfaceView.performDrawFinished:586 android.view.SurfaceView.$r8$lambda$st27mCkd9jfJkTrN_P3qIGKX6NY:0 
D/ViewRootImpl@578a512[MainActivity](21250): pendingDrawFinished. Waiting on draw reported mDrawsNeededToReport=1
I/flutter (21250): Deep Link Service initialized
D/ViewRootImpl@578a512[MainActivity](21250): Creating frameDrawingCallback nextDrawUseBlastSync=false reportNextDraw=true hasBlurUpdates=false
D/ViewRootImpl@578a512[MainActivity](21250): Creating frameCompleteCallback
I/SurfaceView@5e0e8f3(21250): uSP: rtp = Rect(0, 0 - 1080, 2154) rtsw = 1080 rtsh = 2154
I/SurfaceView@5e0e8f3(21250): onSSPAndSRT: pl = 0 pt = 0 sx = 1.0 sy = 1.0
I/SurfaceView@5e0e8f3(21250): aOrMT: uB = true t = android.view.SurfaceControl$Transaction@28fc3f fN = 1 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1728 android.graphics.RenderNode$CompositePositionUpdateListener.positionChanged:319 
I/SurfaceView@5e0e8f3(21250): aOrMT: vR.mWNT, vR = ViewRootImpl@578a512[MainActivity]
I/ViewRootImpl@578a512[MainActivity](21250): mWNT: t = android.view.SurfaceControl$Transaction@28fc3f fN = 1 android.view.SurfaceView.applyOrMergeTransaction:1628 android.view.SurfaceView.access$500:124 android.view.SurfaceView$SurfaceViewPositionUpdateListener.positionChanged:1728 
I/ViewRootImpl@578a512[MainActivity](21250): mWNT: merge t to BBQ
D/ViewRootImpl@578a512[MainActivity](21250): Received frameDrawingCallback frameNum=1. Creating transactionCompleteCallback=false
D/ViewRootImpl@578a512[MainActivity](21250): Received frameCompleteCallback  lastAcquiredFrameNum=1 lastAttemptedDrawFrameNum=1
I/ViewRootImpl@578a512[MainActivity](21250): [DP] pdf(0) 1 android.view.ViewRootImpl.lambda$addFrameCompleteCallbackIfNeeded$3$ViewRootImpl:5000 android.view.ViewRootImpl$$ExternalSyntheticLambda16.run:6 android.os.Handler.handleCallback:938 
I/ViewRootImpl@578a512[MainActivity](21250): [DP] rdf()
D/ViewRootImpl@578a512[MainActivity](21250): reportDrawFinished (fn: -1) 
D/InsetsSourceConsumer(21250): ensureControlAlpha: for ITYPE_NAVIGATION_BAR on com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity
D/InsetsSourceConsumer(21250): ensureControlAlpha: for ITYPE_STATUS_BAR on com.zazadance.zaza_dance/com.zazadance.zaza_dance.MainActivity
I/flutter (21250): PushNotificationService initialized successfully
I/ViewRootImpl@578a512[MainActivity](21250): MSG_WINDOW_FOCUS_CHANGED 1 1
D/InputMethodManager(21250): startInputInner - Id : 0
I/InputMethodManager(21250): startInputInner - mService.startInputOrWindowGainedFocus

