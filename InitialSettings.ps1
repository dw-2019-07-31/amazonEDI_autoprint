$driver_path = "\\dwfs.dad-way.local\open\ADIV\ICTG\90_�C���X�g�[���[\91_Ruby\chromedriver_win32\chromedriver.exe"
$env_path = "C:\Ruby25-x86\bin"

Copy-Item -Path $driver_path -Destination $env_path -Force

if ($? -eq $true){
    echo "chromedriver�̃R�s�[�ɐ������܂����B"
}
else{
    echo "chromedriver�̃R�s�[�Ɏ��s���܂����B"
}

gem install selenium-webdriver -v "3.14.0"

if ($? -eq $true){
    echo "selenium�̃C���X�g�[���������܂����B"
}
else{
    echo "selenium�̃C���X�g�[�����s���܂����B"
}

echo "�����ŋN������Google Chrome�ɁAAmazonEDI�p�̈���ݒ���s���Ă��������B"
ruby .\bin\change_print_settings.rb

Read-Host "�������I�����܂��BEnter �L�[�������Ă�������..."