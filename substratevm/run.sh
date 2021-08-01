#!/bin/bash

RTJAR_1_PATH="/home/vasyoid/openjdk-8u292b10/openjdk-8u292-b10/jre/lib/rt.jar"
RTJAR_2_PATH="/home/vasyoid/openjdk-8u292b10/openjdk-8u292-b10/jre/lib/rt.jar"
TEST_CLASS=$1
DUMP_DIR="$2_"

TEST_CLASS_LOWER_CASE=$(echo "$TEST_CLASS" | tr '[:upper:]' '[:lower:]')

run_on_jar () {
	mv "$JAVA_HOME/jre/lib/rt.jar" "$JAVA_HOME/jre/lib/rt.jar-backup"
	cp "$1" "$JAVA_HOME/jre/lib/"

	/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/bin/java \
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
	-Djvmci.class.path.append=/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/jvmci/graal.jar \
	-Djdk.internal.lambda.disableEagerInitialization=true \
	-Djdk.internal.lambda.eagerlyInitialize=false \
	-Djava.lang.invoke.InnerClassLambdaMetafactory.initializeLambdas=false \
	-Dllvm.bin.dir=/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/LLVM_TOOLCHAIN/bin/ \
	-javaagent:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/svm.jar \
	-Xbootclasspath/a:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/boot/graal-sdk.jar \
	-cp \
	/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/objectfile.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/pointsto.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/javacpp-shadowed.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/llvm-platform-specific-shadowed.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/llvm-wrapper-shadowed.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/svm-llvm.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/builder/svm.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/jvmci/jvmci-api.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/jvmci/graal-management.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/jvmci/graal.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/jvmci/graal-truffle-jfr-impl.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/jvmci/jvmci-hotspot.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/resources.jar \
	com.oracle.svm.hosted.NativeImageGeneratorRunner \
	-imagecp \
	/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/boot/graal-sdk.jar:/home/vasyoid/study/java-coverage-analysis/graal-8/substratevm:/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/library-support.jar \
	-H:Path="$PWD" \
	-H:CLibraryPath=/home/vasyoid/study/java-coverage-analysis/graal-8/substratevm/mxbuild/linux-amd64/SVM_HOSTED_NATIVE/linux-amd64 \
	-H:CLibraryPath=/home/vasyoid/study/java-coverage-analysis/graal-8/sdk/mxbuild/linux-amd64/GRAALVM_52AFF0064F_JAVA8/graalvm-52aff0064f-java8-21.2.0-dev/jre/lib/svm/clibraries/linux-amd64 \
	"-H:Class@explicit main-class=$TEST_CLASS" \
	"-H:Name@main-class lower case as image name=$TEST_CLASS_LOWER_CASE" \
	-H:-AOTInline \
	-H:+PrintCanonicalGraphStrings \
	-H:+DumpGraphsForCoverage \
	-H:PrintCanonicalGraphStringFlavor=3 \
	-H:+CanonicalGraphStringsCheckConstants \
	-H:DumpPath="graal_dumps/$DUMP_DIR/$2"

	mv "$JAVA_HOME/jre/lib/rt.jar-backup" "$JAVA_HOME/jre/lib/rt.jar"	
}

run_on_jar $RTJAR_1_PATH 1 no_debug
run_on_jar $RTJAR_2_PATH 2 no_debug
