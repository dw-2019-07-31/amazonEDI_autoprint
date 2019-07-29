require './lib/AmazonWebEDI.rb'
require './lib/Csv.rb'
require './lib/Log.rb'
require 'csv'

Log.instance

puts "発注残印刷処理を開始します。Enterを押してください"
gets

csv = Csv.new

#アマゾン注残.csvのPO番号の一覧を取得する
po_numbers = csv.get_baby_po_numbers
Log.info("ベビーのPO番号を取得しました。")

##以下の処理は、print_label.rbと同一
site = AmazonWebEDI.new

if site.login_check()
    site.click_signin()
    puts "ユーザーIDとパスワードを入力してログインしてくだい。次の画面に進んだらEnterを押してください。"
    gets 

    unless site.order_check()
        puts "2段階認証のコードを入力して次の画面に進んでください。次の画面に進んだらEnterを押してください。"
        gets
    end
end

site.click_contact() if site.contact_check()

user = site.get_login_user()
unless user.include?("Baby")
    site.switch_user_account("Baby") 
    puts "アカウントをBabyに切り替えました。"
end

2.times do

    unless po_numbers.empty?
        po_numbers.each do |po_number|
            site.print_shipping_label(po_number) 
            puts "#{site.shipping_label_number}枚の配送ラベルを印刷しました。"
            Log.info("#{site.purchase_order_number}枚の配送ラベルを印刷しました。PO:#{po_number}")
        end        
    else
        puts "印刷対象のPOが存在しません。\r\n開始日：「#{from_hacchubi}」\r\n終了日：「#{to_hacchubi}」"
        Log.info("印刷対象のPOが存在しません。開始日：「#{from_hacchubi}」終了日：「#{to_hacchubi}」")
    end

    user = site.get_login_user()
    unless user.include?("Pet")
        site.switch_user_account("Pet") 
        puts "アカウントをPetに切り替えました。"
        po_numbers = csv.get_pet_po_numbers
        Log.info("ペットのPO番号を取得しました。")
    end

end

# 印刷が完了してからcloseするために、ホーム画面を一度表示する
site.click_home()

site.close_amazon_site()

puts "処理を終了します。Enterを押してください。"
gets
