$driver_path = "\\dwfs.dad-way.local\open\ADIV\ICTG\90_インストーラー\91_Ruby\chromedriver_win32\chromedriver.exe"
$env_path = "C:\Ruby25-x86\bin"

Copy-Item -Path $driver_path -Destination $env_path -Force

if ($? -eq $true){
    echo "chromedriverのコピーに成功しました。"
}
else{
    echo "chromedriverのコピーに失敗しました。"
}

gem install selenium-webdriver -v "3.14.0"

if ($? -eq $true){
    echo "seleniumのインストール成功しました。"
}
else{
    echo "seleniumのインストール失敗しました。"
}

echo "自動で起動するGoogle Chromeに、AmazonEDI用の印刷設定を行ってください。"
ruby .\bin\change_print_settings.rb

Read-Host "処理を終了します。Enter キーを押してください..."