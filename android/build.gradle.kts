allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Several plugins (better_player from AppCore, flutter_keyboard_visibility, etc.)
// hard-pin a low compileSdk, but their transitive androidx deps now require >= 36.
// Register the afterEvaluate hook BEFORE the evaluationDependsOn block below,
// otherwise subprojects are already evaluated and the hook is rejected.
// Groovy interop avoids an AGP classpath import here.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        val current = androidExt.withGroovyBuilder { getProperty("compileSdkVersion") } as? String
        val currentLevel = current?.removePrefix("android-")?.toIntOrNull() ?: 0
        if (currentLevel < 36) {
            androidExt.withGroovyBuilder { "compileSdkVersion"(36) }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
