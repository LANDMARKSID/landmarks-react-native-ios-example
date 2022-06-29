FRAMEWORK_NAME=LandmarksIDSDK
ARCHIVE_BASE_PATH=/tmp/archive-$FRAMEWORK_NAME
rm -r $ARCHIVE_BASE_PATH
mkdir $ARCHIVE_BASE_PATH

IPHONEOS_ARCHIVE_PATH=$ARCHIVE_BASE_PATH/${FRAMEWORK_NAME}_Release_iphoneos.xcarchive
IPHONESIMULATOR_ARCHIVE_PATH=$ARCHIVE_BASE_PATH/${FRAMEWORK_NAME}_Release_iphonesimulator.xcarchive

IPHONEOS_FRAMEWORK_PATH=$IPHONEOS_ARCHIVE_PATH/Products/Library/Frameworks/$FRAMEWORK_NAME.framework
IPHONESIMULATOR_FRAMEWORK_PATH=$IPHONESIMULATOR_ARCHIVE_PATH/Products/Library/Frameworks/$FRAMEWORK_NAME.framework

xcodebuild archive \
	-project $FRAMEWORK_NAME.xcodeproj \
	-scheme $FRAMEWORK_NAME \
	-configuration Release \
	-sdk iphoneos \
	-archivePath $IPHONEOS_ARCHIVE_PATH \
	SKIP_INSTALL=NO \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
	-project $FRAMEWORK_NAME.xcodeproj \
	-scheme $FRAMEWORK_NAME \
	-configuration Release \
	-sdk iphonesimulator \
	-archivePath $IPHONESIMULATOR_ARCHIVE_PATH \
	SKIP_INSTALL=NO \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
	-framework $IPHONEOS_FRAMEWORK_PATH \
    -framework $IPHONESIMULATOR_FRAMEWORK_PATH \
    -output $ARCHIVE_BASE_PATH/$FRAMEWORK_NAME.xcframework
    
open $ARCHIVE_BASE_PATH
