# Статический анализ

### Необходимые зависимости
Перед тем, как запустить скрипт, необходимо скачать:
* https://github.com/graalvm/mx
* https://github.com/graalvm/graal-jvmci-8/releases (точно подойдет jvmci-20.3-b22)

### Сборка компонентов

```
mx build
javac DumpComparator.java
```

### Запуск скрипта

1) Поумолчанию скрипт запускает анализ для классов HelloWorld.java и Helper.java. Перед запуском их надо скомпилировать:

```
javac HelloWorld.java Helper.java
```

2) В файле `config` необходимо изменить переменные среды, которые будут задействованы скриптом `run.sh`

3) Запускаем скрипт

```
./run.sh
```

По умолчанию результат будет в `./graal_dumps/dump/`

### Задачи на будущее

* Доработать вывод текстового представления графа, в `medium` представлении (`CanonicalStringGraphPrinter.writeCanonicalGraphExpressionString()`)
    * Добавить текстовое представление для некоторых классов (например `IntegerLessThanNode$LessThanOp`)
    * Убрать лишний вывод (например информацию для оптимизации)
    * Убедиться, что совпадающие хеши лямбд в представлении $AnalysisMethod$ гарантируют совпадение исходных лямбд:
    ```
    HostedMethod<JNIInvocationInterface$Support$$Lambda$bd803f96b0c13e255e3d34d1dd3fb40d56c66928.accept -> AnalysisMethod<com.oracle.svm.jni.functions.JNIInvocationInterface$Support$$Lambda$bd803f96b0c13e255e3d34d1dd3fb40d56c66928.accept -> HotSpotMethod<JNIInvocationInterface$Support$$Lambda$374/924323747.accept(Object, Object)>>>
    ```
* Изучить, какие классы или методы graal заменяет на свои, и насколько это портит анализ. Например, в класс `Object` добавляется метод `getInterfaces()`
```
HostedMethod<Class.getInterfaces -> AnalysisMethod<java.lang.Class.getInterfaces -> HotSpotMethod<DynamicHub.getInterfaces(DynamicHub, boolean)>>>
```
* Изучить остальные виды различий в дифе между двумя запусками на одних и тех же входных данных
```
java.lang.Class.getMonitorOffset()
line 2:
>>> LoadFieldNode<3>({stamp}: i32 [-32768 - 32767], {volatileAccess}: false, {field}: HostedField<Class.monitorOffset location: 166   AnalysisField<Class.monitorOffset accessed: false reads: true written: false>>, {uncheckedStamp}: null, {input positions}: ParameterNode<1>({stamp}: a!# java.lang.Class, {index}: 0, {uncheckedStamp}: null{input positions}: ))
<<< LoadFieldNode<3>({stamp}: i32 [-32768 - 32767], {volatileAccess}: false, {field}: HostedField<Class.monitorOffset location: 164   AnalysisField<Class.monitorOffset accessed: false reads: true written: false>>, {uncheckedStamp}: null, {input positions}: ParameterNode<1>({stamp}: a!# java.lang.Class, {index}: 0, {uncheckedStamp}: null{input positions}: ))
```
```
org.graalvm.compiler.options.OptionValues$1.compare(org.graalvm.compiler.options.OptionKey, org.graalvm.compiler.options.OptionKey)
line 9:
>>> InvokeWithExceptionNode<21>({stamp}: a# java.lang.String, {bci}: 1, {polymorphic}: false, {inlineControl}: Normal, {input positions}: null, SubstrateMethodCallTargetNode<14>({stamp}: void, {targetMethod}: HostedMethod<OptionKey.getName -> AnalysisMethod<org.graalvm.compiler.options.OptionKey.getName -> HotSpotMethod<OptionKey.getName()>>>, {referencedType}: null, {invokeKind}: Special, {returnStamp}: a# java.lang.String, {profile}: JavaTypeProfile<nullSeen=FALSE, types=[0.166667:HostedType<com.oracle.svm.core.SubstrateGCOptions$1   AnalysisType<com.oracle.svm.core.SubstrateGCOptions$1, allocated: false, inHeap: true, reachable: true>>, 0.166667:HostedType<com.oracle.svm.core.SubstrateGCOptions$2   AnalysisType<com.oracle.svm.core.SubstrateGCOptions$2, allocated: false, inHeap: true, reachable: true>>, 0.166667:HostedType<com.oracle.svm.core.SubstrateGCOptions$3   AnalysisType<com.oracle.svm.core.SubstrateGCOptions$3, allocated: false, inHeap: true, reachable: true>>, 0.166667:HostedType<com.oracle.svm.core.SubstrateOptions$3   AnalysisType<com.oracle.svm.core.SubstrateOptions$3, allocated: false, inHeap: true, reachable: true>>, 0.166667:HostedType<com.oracle.svm.core.option.RuntimeOptionKey   AnalysisType<com.oracle.svm.core.option.RuntimeOptionKey, allocated: false, inHeap: true, reachable: true>>, 0.166667:HostedType<org.graalvm.compiler.options.OptionKey   AnalysisType<org.graalvm.compiler.options.OptionKey, allocated: false, inHeap: true, reachable: true>>], notRecorded:0.000000>, {bci}: 1, {staticAnalysisResults}: com.oracle.graal.pointsto.results.StaticAnalysisResults, {input positions}: PiNode<13>({stamp}: a! org.graalvm.compiler.options.OptionKey, {piStamp}: a! -, {input positions}: BeginNode, ParameterNode<2>({stamp}: a org.graalvm.compiler.options.OptionKey, {index}: 1, {uncheckedStamp}: null {input positions}: ))), null, FrameState)
<<< InvokeWithExceptionNode<21>({stamp}: a# java.lang.String, {bci}: 1, {polymorphic}: false, {inlineControl}: Normal, {input positions}: null, SubstrateMethodCallTargetNode<14>({stamp}: void, {targetMethod}: HostedMethod<OptionKey.getName -> AnalysisMethod<org.graalvm.compiler.options.OptionKey.getName -> HotSpotMethod<OptionKey.getName()>>>, {referencedType}: null, {invokeKind}: Special, {returnStamp}: a# java.lang.String, {profile}: null, {bci}: 1, {staticAnalysisResults}: com.oracle.graal.pointsto.results.StaticAnalysisResults, {input positions}: PiNode<13>({stamp}: a! org.graalvm.compiler.options.OptionKey, {piStamp}: a! -, {input positions}: BeginNode, ParameterNode<2>({stamp}: a org.graalvm.compiler.options.OptionKey, {index}: 1, {uncheckedStamp}: null {input positions}: ))), null, FrameState)
```
```
com.oracle.svm.core.SubstrateDiagnostics.print(com.oracle.svm.core.log.Log, org.graalvm.word.Pointer, org.graalvm.nativeimage.c.function.CodePointer)
line 2:
>>> InvokeWithExceptionNode<10>({stamp}: void, {bci}: 9, {polymorphic}: false, {inlineControl}: Normal, {input positions}: null, SubstrateMethodCallTargetNode<6>({stamp}: void, {targetMethod}: HostedMethod<SubstrateDiagnostics.print -> AnalysisMethod<com.oracle.svm.core.SubstrateDiagnostics.print -> HotSpotMethod<SubstrateDiagnostics.print(Log, Pointer, CodePointer, RegisterDumper$Context)>>>, {referencedType}: null, {invokeKind}: Static, {returnStamp}: void, {profile}: null, {bci}: 9, {input positions}: ParameterNode<1>({stamp}: a com.oracle.svm.core.log.Log, {index}: 0, {uncheckedStamp}: null{input positions}: ), ParameterNode<2>({stamp}: i64, {index}: 1, {uncheckedStamp}: null{input positions}: ), ParameterNode<3>({stamp}: i64, {index}: 2, {uncheckedStamp}: null{input positions}: ), 0), null, FrameState)
<<< InvokeWithExceptionNode<10>({stamp}: void, {bci}: 9, {polymorphic}: false, {inlineControl}: Never, {input positions}: null, SubstrateMethodCallTargetNode<6>({stamp}: void, {targetMethod}: HostedMethod<SubstrateDiagnostics.print -> AnalysisMethod<com.oracle.svm.core.SubstrateDiagnostics.print -> HotSpotMethod<SubstrateDiagnostics.print(Log, Pointer, CodePointer, RegisterDumper$Context)>>>, {referencedType}: null, {invokeKind}: Static, {returnStamp}: void, {profile}: null, {bci}: 9, {input positions}: ParameterNode<1>({stamp}: a com.oracle.svm.core.log.Log, {index}: 0, {uncheckedStamp}: null{input positions}: ), ParameterNode<2>({stamp}: i64, {index}: 1, {uncheckedStamp}: null{input positions}: ), ParameterNode<3>({stamp}: i64, {index}: 2, {uncheckedStamp}: null{input positions}: ), 0), null, FrameState)
```
```
com.oracle.svm.core.meta.CompressedNullConstant.hashCode()
line 2:
>>> ReturnNode<6>({stamp}: void, {input positions}: 982439127, null)
<<< ReturnNode<6>({stamp}: void, {input positions}: 1956416466, null)
```