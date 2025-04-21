go mod tidy
gop build .
gomobile build --tags canvas  -target=android  -androidapi 29
