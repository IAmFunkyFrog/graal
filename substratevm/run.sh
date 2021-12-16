#!/bin/bash

source ./config

REMOVE_IDENTITIES=true
CHECK_CONSTANTS=false

TEST_CLASS_LOWER_CASE=$(echo "$TEST_CLASS" | tr '[:upper:]' '[:lower:]')

run_on_jar () {
	mv "$GRAAL_BUILDED_JDK/jre/lib/rt.jar" "$GRAAL_BUILDED_JDK/jre/lib/rt.jar-backup"
	cp "$1" "$GRAAL_BUILDED_JDK/jre/lib/"

	$GRAAL_BUILDED_JDK/jre/bin/java \
	-XX:+UseParallelGC \
	-XX:+UnlockExperimentalVMOptions \
	-XX:+EnableJVMCI \
	-XX:-UseJVMCIClassLoader \
	-XX:-UseJVMCICompiler \
	-Dorg.graalvm.version=dev \
	-Dorg.graalvm.config=CE \
	-Dcom.oracle.graalvm.isaot=true \
	-Djava.system.class.loader=com.oracle.svm.hosted.NativeImageSystemClassLoader \
	-Xshare:off \
	-Djvmci.class.path.append=$GRAAL_BUILDED_JDK/jre/lib/jvmci/graal.jar \
	-Djdk.internal.lambda.disableEagerInitialization=true \
	-Djdk.internal.lambda.eagerlyInitialize=false \
	-Djava.lang.invoke.InnerClassLambdaMetafactory.initializeLambdas=false \
	-Dllvm.bin.dir=$GRAAL_PATH/sdk/mxbuild/linux-amd64/LLVM_TOOLCHAIN/bin/ \
	-javaagent:$GRAAL_BUILDED_JDK/jre/lib/svm/builder/svm.jar \
	-Xbootclasspath/a:$GRAAL_BUILDED_JDK/jre/lib/boot/graal-sdk.jar \
	-cp \
	$GRAAL_BUILDED_JDK/jre/lib/svm/builder/objectfile.jar:$GRAAL_BUILDED_JDK/jre/lib/svm/builder/pointsto.jar:$GRAAL_BUILDED_JDK/jre/lib/svm/builder/javacpp-shadowed.jar:$GRAAL_BUILDED_JDK/jre/lib/svm/builder/llvm-platform-specific-shadowed.jar:$GRAAL_BUILDED_JDK/jre/lib/svm/builder/llvm-wrapper-shadowed.jar:$GRAAL_BUILDED_JDK/jre/lib/svm/builder/svm-llvm.jar:$GRAAL_BUILDED_JDK/jre/lib/svm/builder/svm.jar:$GRAAL_BUILDED_JDK/jre/lib/jvmci/jvmci-api.jar:$GRAAL_BUILDED_JDK/jre/lib/jvmci/graal-management.jar:$GRAAL_BUILDED_JDK/jre/lib/jvmci/graal.jar:$GRAAL_BUILDED_JDK/jre/lib/jvmci/graal-truffle-jfr-impl.jar:$GRAAL_BUILDED_JDK/jre/lib/jvmci/jvmci-hotspot.jar:$GRAAL_BUILDED_JDK/jre/lib/resources.jar \
	com.oracle.svm.hosted.NativeImageGeneratorRunner \
	-imagecp \
	$GRAAL_BUILDED_JDK/jre/lib/boot/graal-sdk.jar:$GRAAL_PATH/substratevm:$GRAAL_BUILDED_JDK/jre/lib/svm/library-support.jar \
	-H:Path="$(pwd)" \
	-H:CLibraryPath=$GRAAL_PATH/substratevm/mxbuild/linux-amd64/SVM_HOSTED_NATIVE/linux-amd64 \
	-H:CLibraryPath=$GRAAL_BUILDED_JDK/jre/lib/svm/clibraries/linux-amd64 \
	"-H:Class=$TEST_CLASS" \
	"-H:Name=$TEST_CLASS_LOWER_CASE" \
	-H:-AOTInline \
	-H:+PrintCanonicalGraphStrings \
	-H:+DumpGraphsForCoverage \
	-H:PrintCanonicalGraphStringFlavor=3 \
	$( [[ $REMOVE_IDENTITIES == false ]] && printf %s "-H:-CanonicalGraphStringsRemoveIdentities" ) \
	$( [[ $CHECK_CONSTANTS == true ]] && printf %s "-H:+CanonicalGraphStringsCheckConstants" ) \
	-H:DumpPath="$DUMP_DIR/$2" \

	mv "$GRAAL_BUILDED_JDK/jre/lib/rt.jar-backup" "$GRAAL_BUILDED_JDK/jre/lib/rt.jar"
}

run_on_jar $RTJAR_1_PATH 1
run_on_jar $RTJAR_2_PATH 2

java DumpComparator "$DUMP_DIR/1" "$DUMP_DIR/2" "$DUMP_DIR/diff-medium.txt" "$DUMP_DIR/potentional-diff-medium.txt" medium