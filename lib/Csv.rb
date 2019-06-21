require './lib/Log.rb'
require 'csv'

class Csv

    def initialize
        begin
            @csv = CSV.read('./input/アマゾン注残.csv', headers: true, encoding: "Shift_JIS:UTF-8") 
            Log.info("CSVを読み込みました。")
        rescue => exception
            Log.error("Csvクラスのコンストラクタでエラーです。")
            Log.error(exception)
            exit
        end
    end

    #order_listの中から得意先コードの末尾が1 or 4のもの(ベビー)を抜き出すメソッド
    def get_baby_po_numbers
        begin
            order_list = @csv.select do |order| 
                order['得意先コード'].slice(order['得意先コード'].length - 1,1) == '1' \
                || order['得意先コード'].slice(order['得意先コード'].length - 1,1) == '4'
            end
            po_numbers = order_list.map {|order| order['相手先注文番号']}
            po_numbers.uniq
        rescue => exception
            Log.error("ベビーのPO番号の取得に失敗しました。")
            Log.error(exception)
            exit
        end
    end

    #order_listの中から得意先コードの末尾が2のもの(ペット)を抜き出すメソッド
    def get_pet_po_numbers
        begin
            order_list = @csv.select do |order| 
                order['得意先コード'].slice(order['得意先コード'].length - 1,1) == '2' 
            end
            po_numbers = order_list.map {|order| order['相手先注文番号']}
            po_numbers.uniq
        rescue => exception
            Log.error("ペットのPO番号の取得に失敗しました。")
            Log.error(exception)
            exit
        end
    end

end
