#Make sure to copy the JuceHeader.h 
#and rename the <JuceHeader.h> to "JuceHeader.h"
#First build release Project
# macOS/Linux
chmod +x build.sh && ./build.sh

# Windows
build.bat


#Second Code sign

# to find identity
security find-identity -v -p codesigning

# Replace "Developer ID Application: Your Name (TEAMID)" with your actual identity
IDENTITY="Developer ID Installer: Developer Fullname (ActualKeyNumber)"

codesign --force --deep --sign "Developer ID Application: Developer Fullname (ActualKeyNumber)" --options runtime AU/DX10.component
codesign --force --deep --sign "Developer ID Application: Developer Fullname (ActualKeyNumber)" --options runtime VST3/DX10.vst3
codesign --force --deep --sign "Developer ID Application: Developer Fullname (ActualKeyNumber)" --options runtime Standalone/DX10.app

codesign --force --deep --options runtime --timestamp \          
-s "Apple Distribution: Developer Fullname (ActualKeyNumber)" \
"/Users/Jeb/Documents/JuceProjs/DX10/Builds/MacOSX/build/Release/DX10.app"

#third Zip the artifacts(VST3,AU component and stand alone )

ditto -c -k --keepParent DX10.vst3 DX10_vst3.zip

ditto -c -k --keepParent DX10.component DX10_au.zip

ditto -c -k --keepParent DX10.app DX10_app.zip


#Fourth Then notarize

xcrun notarytool submit DX10_app.zip \
  --apple-id "example@email.com" \
  --password "actual-pass-word" \
  --team-id "ActualKeyNumber" \
  --wait


xcrun notarytool submit DX10_au.zip \
  --apple-id "example@email.com" \
  --password "actual-pass-word" \
  --team-id "ActualKeyNumber" \
  --wait


xcrun notarytool submit DX10_vst3.zip \
  --apple-id "example@email.com" \
  --password "actual-pass-word" \
  --team-id "ActualKeyNumber" \
  --wait

  #Fifth Staple

xcrun stapler staple "DX10_app.zip"
xcrun stapler staple "DX10_vst3.zip"
xcrun stapler staple "DX10_au.zip"


# sixth Make a folder for vst3 and Component and copy the vst3 and component inside those folders respectively




#7th Build an installer PKG

mkdir -p scripts
cat > scripts/postinstall << 'EOF'
#!/bin/bash
# Runs after package installation
echo "DX10 plugin installed successfully!"
# You could add additional setup here
EOF

chmod +x scripts/postinstall

pkgbuild --identifier com.jebjosh.dx10 \
         --version 1.0 \
         --component VST3/DX10.vst3 \
         --component COMPONENTS/DX10.component \
         --scripts scripts \
         --install-location /Library/Audio/Plug-Ins \DX10_InstallerBuild.pkg

productsign --sign \
"Developer ID Installer: Developer Fullname (ActualKeyNumber)" \
DX10_InstallerBuild.pkg JebDX10-signed.pkg

xcrun notarytool submit JebDX10-signed.pkg \
--apple-id "example@email.com" \
--team-id "ActualKeyNumber" \
--password "actual-pass-word" \
--wait
         

xcrun stapler staple "JebDX10-signed.pkg"
xcrun stapler staple "DX10_InstallerBuild.pkg"