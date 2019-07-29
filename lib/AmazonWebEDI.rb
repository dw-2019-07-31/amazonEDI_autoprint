require './lib/WebControl.rb'
require './lib/Log.rb'
require 'Date'

class AmazonWebEDI < WebControl

    attr_reader :shipping_label_number, :purchase_order_number
    SLEEP_TIME = 1.5

    #コンストラクタ
    #chromeをkioskモードで開き、amazonのTOPページに遷移する
    #chromeの印刷ページはseleniumで制御不能なので、chromeのオプションでkioskモードを指定して、印刷ページが開いたら印刷が走るようにしておく必要がある。
    def initialize
        begin
            super
            @shipping_label_number = 0
            @purchase_order_number = 0
            self.get_top_page
        rescue => exception
            Log.error("コンストラクタの処理でエラーです。")
            Log.error("#{exception}")
            close_amazon_site()
            exit
        end
    end

    #TOPページを開く処理
    def get_top_page
        self.get("https://vendorcentral.amazon.co.jp/gp/vendor/sign-in")
        puts "TOPページが開きました。"
    end

    #ログイン処理を自動でやっていた時の名残。今は使ってない。
    def open_top_page(id, password)
        begin
            click_signin()
            login(id, password)
            unless contact_check()
                puts "2段階認証コードを入力して手動でログインしてください。\r\nログイン後Enterを押してください。"
                gets
            end
            click_contact() 
        rescue => exception
            Log.error("サインインできません")
            Log.error("#{exception}")
            close_amazon_site()
            exit
        else
            puts "ログインしました。"
        end
    end

    def click_home
        xpath = '//*[@id="home_topNav"]'
        click_element_by_xpath(xpath)
    end

    def close_amazon_site
        close_browser()
    end

    def login_check
        xpath = '//*[@id="login-button-container"]'
        wait_for_element_by_xpath(xpath,5)
    end

    def order_check
        xpath = '//*[@id="vss_navbar_tab_order_text"]'
        wait_for_element_by_xpath(xpath,5)
    end

    def contact_check
        xpath = '//*[@id="answerContact_no"]'
        wait_for_element_by_xpath(xpath,5)
    end

    def managementPO_check
        xpath = '//*[@id="vss_navbar_tab_order_text"]'
        wait_for_element_by_xpath(xpath)
        click_element_by_xpath(xpath)
        xpath = '//*[@id="vss_navbar_tab_order_content"]/ul/li[1]/a'
        wait_for_element_by_xpath(xpath)
    end

    def click_signin
        xpath = '//*[@id="login-button-container"]'
        click_element_by_xpath(xpath)
    end

    def login(id, password)
        xpath = '//*[@id="ap_email"]'
        send_keys_by_xpath(xpath, id)
        xpath = '//*[@id="ap_password"]'
        send_keys_by_xpath(xpath, password)
        xpath = '//*[@id="signInSubmit"]'
        click_element_by_xpath(xpath)
    end

    def click_contact
        xpath = '//*[@id="answerContact_no"]'
        wait_for_element_by_xpath(xpath)
        click_element_by_xpath(xpath)
    end

    def get_login_user
        xpath = '//*[@id="greetingCell"]'
        user_name = ''
        wait_for_element_by_xpath(xpath)
        elements = find_elements_by_xpath(xpath)
        elements.each do |element|
            user_name = element.text
        end
        user_name
    end

    def click_switch_account
        id = 'vendor-group-switcher_topRightNav'
        wait_for_element_by_id(id)
        click_element_by_id(id)
        xpath = '//*[@id="vendor-group-switch-confirm-button-announce"]'
        wait_for_element_by_xpath(xpath)
        click_element_by_xpath(xpath)
    end

    def switch_user_account(target_user)
        i = 1
        id = 'vendor-group-switcher_topRightNav'
        wait_for_element_by_id(id, 7)
        click_element_by_id(id)
        xpath = '//*[@id="vendor-group-switch-account-form"]/div[1]/div/div/div'
        users = Array.new
        wait_for_element_by_xpath(xpath, 7)
        elements = find_elements_by_xpath(xpath)
        elements.each do |element|
            users = element.text.split("\n")
            users.each do |user|
                target_xpath = "//*[@id='vendor-group-switch-account-form']/div[1]/div/div/div/div[#{i}]/label/span"
                click_element_by_xpath(target_xpath) if user.include?(target_user)
                i += 1
            end
        end
        switch_xpath = '//*[@id="vendor-group-switch-confirm-button-announce"]'
        wait_for_element_by_xpath(switch_xpath, 7)
        submit_element_by_xpath(switch_xpath)
        #@driver.execute_script("document.getElementById('vendor-group-switch-confirm-button-announce').click();")
    end

    def click_target_account
        xpath = '//*[@id="vendor-group-switch-confirm-button-announce"]'
        wait_for_element_by_xpath(xpath)
        click_element_by_xpath(xpath)
    end

    def click_managementPO
        begin
            xpath = '//*[@id="vss_navbar_tab_order_text"]'
            wait_for_element_by_xpath(xpath)
            click_element_by_xpath(xpath)
            xpath = '//*[@id="vss_navbar_tab_order_content"]/ul/li[1]/a'
            wait_for_element_by_xpath(xpath)
            click_element_by_xpath(xpath)
        rescue => exception
            Log.error("PO管理画面が開けません。")
            Log.error("#{exception}")
            close_amazon_site()
            exit
        else
            puts "PO管理画面が開きました。"
        end
    end

    def get_po_numbers(from_hacchubi, to_hacchubi)
        class_name = 'slick-viewport'
        date_and_po = Array.new
        po_numbers = Array.new
        spinner_class_name = 'grid-overlay-spinner'
        wait_for_noelement_by_class(spinner_class_name)
        begin
            while true do
                #「確認済みのPO」の表を丸ごと取ってくる
                elements = find_elements_by_class(class_name)
                elements.each do |element|
                    #JPYでsplitして行を取得
                    rows = element.text.split("JPY\n")
                    end_suffix = rows.length - 1

                    #行の情報からPO番号を抽出
                    rows.each do |row|
                        columns = row.split("\n")
                        @order_date = columns[2]
                        @order_date = Date.strptime(@order_date, "%Y/%m/%d")
                        po_number = columns[0]
                        date_and_po.push([@order_date,po_number])
                    end
                    date_and_po.sort!.reverse!
                    date_and_po.each do |column|
                        @order_date = column[0]
                        po_number = column[1]
                        next if @order_date > to_hacchubi
                        break if @order_date < from_hacchubi
                        po_numbers.push(po_number)
                    end

                end
                #「確認済みのPO」はajax使ってるので表の最終行の発注日が対象期間を抜けるまでスクロールする
                #例：対象期間が2019/07/11～2019/07/12の場合、発注日が2019/07/10が出てくるまでPO番号取得処理を繰り返す。
                if @order_date >= from_hacchubi
                    page_down_by_class(class_name)
                else
                    break
                end
            end
        rescue => exception
            puts "PO番号取得の処理でエラーです。"
            Log.error("PO番号取得の処理でエラーです。")
            Log.error("#{exception}")
            close_amazon_site()
            exit
        end
        po_numbers.uniq!
        po_numbers.sort!
        #return入れないとなぜかエラーになる・・・。
        return po_numbers
    end

    #印刷系の処理で不具合が出ると大方画面描画前に印刷処理が走ってしまうことに原因があるので、wait_for_elementとsleepの処理（待機処理）を散りばめた。
    #印刷処理で不具合が出たらまずsleepの時間を見直してください。
    def print_shipping_label(po_number)
        exec_upper_limit = 3
        exec_number = 0
        #querystringでPO番号を指定すれば、ラベル画面が開ける
        url = "https://vendorcentral.amazon.co.jp/gp/vendor/members/po-management/shipping-label?order-orderId=#{po_number}"
               
        begin
            exec_number += 1
            xpath = '/html/body/div[1]/div[3]/img'

            open_new_tab(url)
            
            loop do 
                wait_for_element_by_xpath(xpath)
                # 配送ラベルページに表示されるバーコードのサイズをjavascriptで取得している。
                # 画像が正常に取得できるまでリロードを繰り返す。
                result = @driver.execute_script('function getElementByXpath(path) {return document.evaluate(path, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;} obj = getElementByXpath("/html/body/div[1]/div[3]/img"); var image = new Image(); image.src = obj.src; var result = image.width; return result;')
                if result != 0
                    break
                else
                    @driver.navigate.refresh
                end
            end
            sleep SLEEP_TIME
            @driver.execute_script('return window.print();')
            puts "PO番号：[#{po_number}]を印刷しています。"
        rescue => exception
            retry if exec_number <  exec_upper_limit
            puts "PO番号：[#{po_number}]でエラーが発生しました。手動で印刷してください。"
            Log.error("PO番号：[#{po_number}]でエラーが発生しました。手動で印刷してください。")
            Log.error("#{exception}")    
        else
            @shipping_label_number += 1
        ensure
            sleep SLEEP_TIME
            close_new_tab()
        end

        if @debug
           gets
        end
        
    end

    #print_shipping_labelとやってることはほぼ一緒
    def print_purchase_order(po_number)
        exec_upper_limit = 3
        exec_number = 0
        url = "https://vendorcentral.amazon.co.jp/st/vendor/members/po-mgmt/order?orderId=#{po_number}"
               
        begin
            exec_number += 1
            
            open_new_tab(url)

            @driver.execute_script("document.body.style.zoom='75%'")
            class_name = 'grid-overlay-spinner'
            sleep SLEEP_TIME
            wait_for_noelement_by_class(class_name)
            @driver.execute_script('return window.print();')
            puts "PO番号：[#{po_number}]を印刷しています。"
        rescue => exception
            retry if exec_number <  exec_upper_limit
            puts "PO番号：[#{po_number}]でエラーが発生しました。手動で印刷してください。"
            Log.error("PO番号：[#{po_number}]でエラーが発生しました。手動で印刷してください。")
            Log.error("#{exception}")
        else
            @purchase_order_number += 1
        ensure
            sleep SLEEP_TIME
            close_new_tab()
        end
    end

    def click_indivisual_PO(url)
        @driver.get "#{url}"
    end

    def open_label
        xpath = '//*[@id="showShippingLabelButton"]'
        wait_for_element_by_xpath(xpath)
        click_element_by_xpath(xpath)
    end

    def click_print_label
        xpath = '//*[@id="printShippingLabelButton"]'
        wait_for_element_by_xpath(xpath)
        click_element_by_xpath(xpath)
    end

end