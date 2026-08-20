#/bin/sh
python3 ./tools/ci_build/build.py \
            --build_dir $build_dir --no_telemetry \
            --config Release \
            --cmake_generator 'Ninja' \
            --update \
            --build \
            --use_xcode \
            --build_shared_lib \
            --compile_no_warning_as_error \
            --cmake_extra_defines onnxruntime_BUILD_UNIT_TESTS=OFF \
            --cmake_extra_defines CMAKE_INSTALL_PREFIX=$build_dir/install/ \
            --cmake_extra_defines CMAKE_OSX_ARCHITECTURES="$arch" \
            --cmake_extra_defines CMAKE_OSX_SYSROOT=macosx \
            --cmake_extra_defines CMAKE_OSX_DEPLOYMENT_TARGET=10.15 \
            --cmake_extra_defines CMAKE_POLICY_VERSION_MINIMUM=3.5 \
            --apple_sysroot macosx \
            --target install \
            --parallel \
            --skip_tests \
            --apple_deploy_target '10.15' \
            $extra_opt
 # see  https://github.com/microsoft/onnxruntime/pull/24194/files
 # for why to use --no_kleidiai


ls -lh $build_dir

tag=$(git rev-parse HEAD)
echo "tag: $tag"

current=$PWD

if true; then
  ls -lh build-macos/$matrixarch/Release/build-macos/$matrixarch/install/lib/libonnxruntime.dylib
  mkdir -p $build_dir/Release

  ARTIFACT_NAME=$artifact
  LIB_NAME=libonnxruntime.dylib
  SOURCE_DIR=$PWD
  COMMIT_ID=$(git rev-parse HEAD)

  BINARY_DIR=build-macos/$matrixarch/Release/build-macos/$matrixarch

  # BINARY_DIR=$build_dir
  cd "$BINARY_DIR"
  mkdir -p $ARTIFACT_NAME/include

  mv -v install/include/onnxruntime/* $ARTIFACT_NAME/include/

  mkdir -p $ARTIFACT_NAME/lib
  cp -v install/lib/libonnxruntime.$version.dylib $ARTIFACT_NAME/lib

  pushd $ARTIFACT_NAME/lib
  name=$(ls libonnxruntime.$version.dylib)
  strip -S $name
  ln -s libonnxruntime.$version.dylib libonnxruntime.dylib
  ls -la
  popd

  #cp -v $SOURCE_DIR/include/onnxruntime/core/providers/coreml/coreml_provider_factory.h  $ARTIFACT_NAME/include

  cp -v $SOURCE_DIR/README.md $ARTIFACT_NAME/README.md
  cp -v $SOURCE_DIR/docs/Privacy.md $ARTIFACT_NAME/Privacy.md
  cp -v $SOURCE_DIR/LICENSE $ARTIFACT_NAME/LICENSE
  cp -v $SOURCE_DIR/ThirdPartyNotices.txt $ARTIFACT_NAME/ThirdPartyNotices.txt
  cp -v $SOURCE_DIR/VERSION_NUMBER $ARTIFACT_NAME/VERSION_NUMBER

  echo $COMMIT_ID > $ARTIFACT_NAME/GIT_COMMIT_ID

  mv -v $ARTIFACT_NAME $current/
  cd $current
  echo "---"
  ls -lh
  echo "---"
  ls -lh $ARTIFACT_NAME
  echo "---"
  ls -lh $ARTIFACT_NAME/lib
  tree $ARTIFACT_NAME
fi

if false; then
  cp -v build-macos/$matrixarch/Release/build-macos/$matrixarch/install/lib/libonnxruntime.dylib $build_dir/Release

  ./tools/ci_build/github/linux/copy_strip_binary.sh \
    -r $build_dir \
    -a $artifact \
    -c Release \
    -l libonnxruntime.dylib \
    -s $PWD/ \
    -t "$(git rev-parse HEAD)"

  mv $build_dir/$artifact ./
fi

rm -rf $build_dir/*
