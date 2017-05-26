Build Instructions

1. download FLEX 4.6 from http://download.macromedia.com/pub/flex/sdk/flex_sdk_4.6.zip
2. install Apache Ant
3. change FLEX_HOME in the build.properties to the path of the extracted FLEX
4. set the build-path in build.properties. This is where the compiled binary will go
5. set the flashjswrapper-path in build.properties.  This is the url of the vpaid bridge when running Flash VPAID in a Javascript VPAID
6. (Optional) set verbose-stacktraces to true if you want to enable verbose stacktraces with Debug version of Flash Player
7. type "ant" to build
