// android/app/src/main/kotlin/com/ddip/MainActivity.kt

package com.ddip

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // ✨ [핵심 수정] onCreate 메소드를 오버라이드하여 윈도우 속성을 변경합니다.
    override fun onCreate(savedInstanceState: Bundle?) {
        // Edge-to-Edge 디스플레이를 활성화합니다.
        // 이 코드는 시스템 바(상태바, 내비게이션 바) 영역까지 앱 컨텐츠가 그려지도록 허용합니다.
        WindowCompat.setDecorFitsSystemWindows(window, false)

        super.onCreate(savedInstanceState)
    }
}