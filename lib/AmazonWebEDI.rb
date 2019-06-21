require './lib/WebControl.rb'
require './lib/Log.rb'
require 'Date'

class AmazonWebEDI < WebControl

    attr_reader :shipping_label_number, :purchase_order_number

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

    def get_top_page
        self.get("https://vendorcentral.amazon.co.jp/gp/vendor/sign-in")
        puts "TOPページが開きました。"
    end

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
                elements = find_elements_by_class(class_name)
                elements.each do |element|
                    rows = element.text.split("JPY\n")
                    end_suffix = rows.length - 1

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
        return po_numbers
    end

    def print_shipping_label(po_number)
        exec_upper_limit = 3
        exec_number = 0
        url = "https://vendorcentral.amazon.co.jp/gp/vendor/members/po-management/shipping-label?order-orderId=#{po_number}"
               
        begin
            exec_number += 1
            xpath = '/html/body/div[1]/div[3]/img'

            open_new_tab(url)
            wait_for_element_by_xpath(xpath)
            sleep 0.8
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
            sleep 0.8
            close_new_tab()
        end

        if @debug
           gets
        end
        
    end

    def print_purchase_order(po_number)
        exec_upper_limit = 3
        exec_number = 0
        url = "https://vendorcentral.amazon.co.jp/st/vendor/members/po-mgmt/order?orderId=#{po_number}"
               
        begin
            exec_number += 1
            
            open_new_tab(url)

            @driver.execute_script("document.body.style.zoom='75%'")
            class_name = 'grid-overlay-spinner'
            sleep 0.7
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
            sleep 0.7
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