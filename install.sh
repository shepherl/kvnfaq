# ID FoxyProxy: gomekmidlodpcbbmibiiaebmhpbhhlca
EXTENSION_ID="gomekmidlodpcbbmibiiaebmhpbhhlca"
CRX_URL="https://clients2.google.com/service/update2/crx?response=redirect&os=mac&arch=arm64&os_arch=arm64&nacl_arch=arm64&prod=chromecrx&prodchannel=&prodversion=120.0.6099.129&lang=en-US&acceptformat=crx3&x=id%3D${EXTENSION_ID}%26installsource%3Dondemand%26uc"

echo "📦 Вызываем окно установки FoxyProxy..."
open -a "Google Chrome" "$CRX_URL"
