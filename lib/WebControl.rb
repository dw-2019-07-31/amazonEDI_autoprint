
# ↓↓↓ 神ドキュメント（seleniumメソッド集）↓↓↓
# https://www.seleniumqref.com/api/webdriver_abc_ruby.html


require 'selenium-webdriver'

class WebControl

    def initialize
        @debug = false
        if @debug
            caps = Selenium::WebDriver::Remote::Capabilities.chrome(
                chromeOptions: {
                    args: [
                        "--user-data-dir=.\\etc\\profile"
                    ]
                }
            )
            @driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
        else
            caps = Selenium::WebDriver::Remote::Capabilities.chrome(
                chromeOptions: {
                    args: [
                        "--user-data-dir=.\\etc\\profile",
                        "--kiosk-printing"
                    ]
                }
            )
            @driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
        end
    end

    def close_browser
        @driver.close
    end

    def get(url)
        @driver.get url
    end

    def open_new_tab(url)
        @driver.execute_script("window.open(arguments[0], 'newtab')", "#{url}")
        @all_handles = @driver.window_handles
        @driver.switch_to.window(@all_handles[1])
    end

    def close_new_tab
        @driver.close
        @driver.switch_to.window(@all_handles[0])
    end

    def send_keys_by_id(id, value)
        Log.info("elements( " + id + " )に " + value + " を設定します。")
        @driver.find_element(:id, id).send_keys(value)
    end

    def send_keys_by_name(name, value)
        Log.info("elements( " + name + " )に " + value + " を設定します。")
        @driver.find_element(:name, name).send_keys(value)
    end

    def send_keys_by_xpath(xpath, value)
        Log.info("elements( " + xpath + " )に " + value + " を設定します。")
        @driver.find_element(:xpath, xpath).send_keys(value)
    end

    def send_keys_by_class(class_name, value)
        Log.info("elements( " + class_name + " )に " + value + " を設定します。")
        @driver.find_element(:class, class_name).send_keys(value)
    end

    def page_down_by_class(class_name)
        Log.info("elements( " + class_name + " )にページダウンを設定します。")
        @driver.find_element(:class, class_name).send_keys(:page_down)
    end
   
    def click_element_by_id(id)
        Log.info("elements( " + id + " )をクリックします。")
        @driver.find_element(:id, id).click
    end
    
    def click_element_by_name(name)
        Log.info("elements( " + name + " )をクリックします。")
        @driver.find_element(:name, name).click
    end

    def click_element_by_class(class_name)
        Log.info("elements( " + class_name + " )をクリックします。")
        @driver.find_element(:class, class_name).click
    end

    def click_element_by_xpath(xpath)
        Log.info("elements( " + xpath + " )をクリックします。")
        @driver.find_element(:xpath, xpath).click
    end

    def click_element_by_link_text(link_text)
        Log.info("elements( " + link_text + " )をクリックします。")
        @driver.find_element(:partial_link_text, link_text).click
    end

    def submit_element_by_xpath(xpath)
        Log.info("elements( " + xpath + " )をクリックします。")
        @driver.find_element(:xpath, xpath).submit
    end

    def find_element_by_xpath(xpath)
        Log.info("elements( " + xpath + " )を探します。")
        @driver.find_element(:xpath, xpath)
    end

    def find_element_by_class(class_name)
        Log.info("elements( " + class_name + " )を探します。")
        @driver.find_element(:class, class_name)
    end

    def find_elements_by_class(class_name)
        Log.info("elements( " + class_name + " )を探します。")
        @driver.find_elements(:class, class_name)
    end

    def find_elements_by_xpath(xpath)
        Log.info("elements( " + xpath + " )を探します。")
        @driver.find_elements(:xpath, xpath)
    end
      
    def wait_for_element_by_id(id, timeout=3)
        wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
        Log.info("elements( " + id + " )を探しています...(timeout = " + timeout.to_s + " sec)")
        begin
            wait.until { @driver.find_element(:id => id) }
        rescue
            Log.info("elements( " + id + " )を見つけることができませんでした。")
            return false
        end
    
        Log.info("elements( " + id + " )を見つけました。")
        true
    end

    def wait_for_element_by_xpath(xpath, timeout=3)
        wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
        Log.info("elements( " + xpath + " )を探しています...(timeout = " + timeout.to_s + " sec)")
        begin
            wait.until { @driver.find_element(:xpath => xpath) }
        rescue
            Log.info("elements( " + xpath + " )を見つけることができませんでした。")
            return false
        end
    
        Log.info("elements( " + xpath + " )を見つけました。")
        true
    end

    def wait_for_element_by_link_text(link_text, timeout=3)
        wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
        Log.info("elements( " + link_text + " )を探しています...(timeout = " + timeout.to_s + " sec)")
        begin
            wait.until { @driver.find_element(:partial_link_text, link_text) }
        rescue
            Log.info("elements( " + link_text + " )を見つけることができませんでした。")
            return false
        end
    
        Log.info("elements( " + link_text + " )を見つけました。")
        true
    end

    def wait_for_element_by_class(class_name, timeout=3)
        wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
        Log.info("elements( " + class_name + " )を探しています...(timeout = " + timeout.to_s + " sec)")
        begin
            wait.until { @driver.find_element(:class => class_name) }
        rescue
            Log.info("elements( " + class_name + " )を見つけることができませんでした。")
            return false
        end
    
        Log.info("elements( " + class_name + " )を見つけました。")
        true
    end

    def wait_for_noelement_by_class(class_name, timeout=3)
        wait_for_element_by_class(class_name)
        while true
            begin
                sleep timeout 
                @driver.find_element(:class => class_name) 
            rescue
                Log.info("elements( " + class_name + " )を見つけることができませんでした。")
                break
            end
        end
        sleep 3
        #Log.info("elements( " + class_name + " )を見つけました。")
        true
    end

    def wait_for_element_effect_by_xpath(xpath, timeout=10)
        wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
        Log.info("elements( " + xpath + " )を探しています...(timeout = " + timeout.to_s + " sec)")
        begin
            wait.until { @driver.find_element(:xpath => xpath).enabled? }
        rescue
            Log.info("elements( " + xpath + " )を見つけることができませんでした。")
            return false
        end
    
        Log.info("elements( " + xpath + " )を見つけました。")
        true
    end

    def wait_for_element_effect_by_class(class_name, timeout=10)
        wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
        Log.info("elements( " + class_name + " )を探しています...(timeout = " + timeout.to_s + " sec)")
        begin
            wait.until { @driver.find_element(:class => class_name).enabled? }
        rescue
            Log.info("elements( " + class_name + " )を見つけることができませんでした。")
            return false
        end
    
        Log.info("elements( " + class_name + " )を見つけました。")
        true
    end
    
end