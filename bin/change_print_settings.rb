require 'selenium-webdriver'

caps = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: {
        args: [
            "--user-data-dir=.\\etc\\profile"
        ]
    }
)
driver = Selenium::WebDriver.for :chrome, desired_capabilities: caps
gets