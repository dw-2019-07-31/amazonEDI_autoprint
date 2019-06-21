require './lib/AmazonWebEDI.rb'
require './lib/Log.rb'

Log.instance

puts "処理を開始します。"

while true
  print "開始日をYYYYMMDD形式で入力してください >> "
  from_hacchubi = gets
  begin
      Date.strptime(from_hacchubi, "%Y%m%d")
  rescue
      p "正しい値を入力してください。"
      next
  end

  break
end

while true
  print "終了日をYYYYMMDD形式で入力してください >> "
  to_hacchubi = gets
  to_hacchubi = from_hacchubi if to_hacchubi == "\n"
  begin
      Date.strptime(to_hacchubi, "%Y%m%d")
  rescue => exception
      p exception
      p "正しい値を入力してください。"
      next
  end
      
  if from_hacchubi > to_hacchubi
      p "エラー：終了日が開始日より過去の日付になってるよ"
      next 
  end

  break
end

from_hacchubi = Date.strptime(from_hacchubi, "%Y%m%d")
to_hacchubi = Date.strptime(to_hacchubi, "%Y%m%d")

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

i = 0

2.times do

    site.click_managementPO() if site.managementPO_check()

    puts "発注日を降順でソートしてください。ソートしたらEnterを押してください。"
    gets

    po_number = Array.new
    po_numbers = site.get_po_numbers(from_hacchubi, to_hacchubi)

    unless po_numbers.empty?

        po_numbers.each do |po_number|
            site.print_purchase_order(po_number)
            Log.info("#{site.purchase_order_number}枚の発注書を印刷しました。PO:#{po_number}")
            puts "#{site.purchase_order_number}枚の発注書を印刷しました。"
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
    end

end

# 印刷が完了してからcloseするために、ホーム画面を一度表示する
site.click_home()

site.close_amazon_site()

puts "処理を終了します。Enterを押してください。"
gets
