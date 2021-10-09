#!/bin/bash

GRAAL_PATH=/home/stepan-trefilov/IdeaProjects/graal/sdk/mxbuild/linux-amd64/GRAALVM_CE0C781D19_JAVA8/graalvm-ce0c781d19-java8-21.2.0-dev

RTJAR_1_PATH="/home/stepan-trefilov/openjdk1.8.0_252-jvmci-20.1-b02/jre/lib/rt.jar"
RTJAR_2_PATH="/home/stepan-trefilov/openjdk1.8.0_302-jvmci-20.3-b22/jre/lib/rt.jar"
REMOVE_IDENTITIES=false
TEST_CLASS="HelloWorld"
DUMP_DIR="graal_dumps/compare"

TEST_CLASS_LOWER_CASE=$(echo "$TEST_CLASS" | tr '[:upper:]' '[:lower:]')

run_on_jar () {
	mv "$GRAAL_PATH/jre/lib/rt.jar" "$GRAAL_PATH/jre/lib/rt.jar-backup"
	cp "$1" "$GRAAL_PATH/jre/lib/"

	$GRAAL_PATH/jre/bin/java \
	$( [[ $3 == debug ]] && printf %s '-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=8000' ) \
	-XX:+UseParallelGC \
	-XX:+UnlockExperimentalVMOptions \
	-XX:+EnableJVMCI \
	-Dtruffle.TrustAllTruffleRuntimeProviders=true \
	-Dtruffle.TruffleRuntime=com.oracle.truffle.api.impl.DefaultTruffleRuntime \
	-Dgraalvm.ForcePolyglotInvalid=true \
	-Dgraalvm.locatorDisabled=true \
	-d64 \
	-XX:-UseJVMCIClassLoader \
	-XX:-UseJVMCICompiler \
	-Xss10m \
	-Xms1g \
	-Xmx13278383304 \
	-Duser.country=US \
	-Duser.language=en \
	-Djava.awt.headless=true \
	-Dorg.graalvm.version=dev \
	-Dorg.graalvm.config=CE \
	-Dcom.oracle.graalvm.isaot=true \
	-Djava.system.class.loader=com.oracle.svm.hosted.NativeImageSystemClassLoader \
	-Xshare:off \
	-Djvmci.class.path.append=$GRAAL_PATH/jre/lib/jvmci/graal.jar \
	-Djdk.internal.lambda.disableEagerInitialization=true \
	-Djdk.internal.lambda.eagerlyInitialize=false \
	-Djava.lang.invoke.InnerClassLambdaMetafactory.initializeLambdas=false \
	-Dllvm.bin.dir=/home/stepan-trefilov/IdeaProjects/graal/sdk/mxbuild/linux-amd64/LLVM_TOOLCHAIN/bin/ \
	-javaagent:$GRAAL_PATH/jre/lib/svm/builder/svm.jar \
	-Xbootclasspath/a:$GRAAL_PATH/jre/lib/boot/graal-sdk.jar \
	-cp \
	$GRAAL_PATH/jre/lib/svm/builder/objectfile.jar:$GRAAL_PATH/jre/lib/svm/builder/pointsto.jar:$GRAAL_PATH/jre/lib/svm/builder/javacpp-shadowed.jar:$GRAAL_PATH/jre/lib/svm/builder/llvm-platform-specific-shadowed.jar:$GRAAL_PATH/jre/lib/svm/builder/llvm-wrapper-shadowed.jar:$GRAAL_PATH/jre/lib/svm/builder/svm-llvm.jar:$GRAAL_PATH/jre/lib/svm/builder/svm.jar:$GRAAL_PATH/jre/lib/jvmci/jvmci-api.jar:$GRAAL_PATH/jre/lib/jvmci/graal-management.jar:$GRAAL_PATH/jre/lib/jvmci/graal.jar:$GRAAL_PATH/jre/lib/jvmci/graal-truffle-jfr-impl.jar:$GRAAL_PATH/jre/lib/jvmci/jvmci-hotspot.jar:$GRAAL_PATH/jre/lib/resources.jar \
	com.oracle.svm.hosted.NativeImageGeneratorRunner \
	-imagecp \
	$GRAAL_PATH/jre/lib/boot/graal-sdk.jar:/home/stepan-trefilov/IdeaProjects/graal/substratevm:$GRAAL_PATH/jre/lib/svm/library-support.jar \
	-H:Path="$(pwd)" \
	-H:CLibraryPath=/home/stepan-trefilov/IdeaProjects/graal/substratevm/mxbuild/linux-amd64/SVM_HOSTED_NATIVE/linux-amd64 \
	-H:CLibraryPath=$GRAAL_PATH/jre/lib/svm/clibraries/linux-amd64 \
	"-H:Class@explicit main-class=$TEST_CLASS" \
	"-H:Name@main-class lower case as image name=$TEST_CLASS_LOWER_CASE" \
	-H:-AOTInline \
	-H:+PrintCanonicalGraphStrings \
	-H:+DumpGraphsForCoverage \
	-H:PrintCanonicalGraphStringFlavor=3 \
	-H:+CanonicalGraphStringsCheckConstants \
	$( [[ $REMOVE_IDENTITIES == false ]] && printf %s "-H:-CanonicalGraphStringsRemoveIdentities" ) \
	-H:DumpPath="$DUMP_DIR/$2" \

	mv "$GRAAL_PATH/jre/lib/rt.jar-backup" "$GRAAL_PATH/jre/lib/rt.jar"
}

run_on_jar $RTJAR_1_PATH 1 no_debug
run_on_jar $RTJAR_2_PATH 2 no_debug

java DumpComparator "$DUMP_DIR/1" "$DUMP_DIR/2" "$DUMP_DIR/diff-full.txt" full
java DumpComparator "$DUMP_DIR/1" "$DUMP_DIR/2" "$DUMP_DIR/diff-medium.txt" medium
java DumpComparator "$DUMP_DIR/1" "$DUMP_DIR/2" "$DUMP_DIR/diff-small.txt" small