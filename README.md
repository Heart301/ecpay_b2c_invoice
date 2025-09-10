# Ecpay B2C Invoice 綠界 B2C 電子發票 (非官方)

Ruby client library for ECPay B2C electronic invoice API integration.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ecpay_b2c_invoice'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ecpay_b2c_invoice

## Configuration

```ruby
Ecpay::B2CInvoice.configure do |config|
  config.merchant_id = "your_merchant_id"
  config.hash_key = "your_hash_key"
  config.hash_iv = "your_hash_iv"
  config.environment = :sandbox # or :production
end
```

## Usage

### Create Invoice

```ruby
client = Ecpay::B2CInvoice::Client.new

invoice_data = {
  RelateNumber: "ORDER_20231201001",
  CustomerName: "王小明",
  CustomerEmail: "customer@example.com",
  SalesAmount: 1000,
  Items: [
    {
      ItemName: "商品A",
      ItemCount: 1,
      ItemWord: "個",
      ItemPrice: 1000,
      ItemAmount: 1000
    }
  ],
  TaxType: "1",
  Print: "0",
  Donation: "0"
}

result = client.issue_invoice(invoice_data)

if result[:success]
  puts "Invoice created successfully!"
  puts "Invoice Number: #{result[:data]['InvoiceNo']}"
  puts "Invoice Date: #{result[:data]['InvoiceDate']}"
else
  puts "Error: #{result[:error]}"
end
```

### Query Government Invoice Word Settings (查詢財政部配號結果)

```ruby
client = Ecpay::B2CInvoice::Client.new

# Query allocation results from Ministry of Finance
result = client.get_gov_invoice_word_setting("113") # Taiwan year format

if result[:success]
  puts "Government allocation found!"
  puts result[:data]
else
  puts "Error: #{result[:error]}"
end
```

### Add Invoice Word Setting (字軌與配號設定)

```ruby
client = Ecpay::B2CInvoice::Client.new

setting_data = {
  InvoiceTerm: 1,           # Invoice period (1-6)
  InvoiceYear: "113",       # Taiwan year format
  InvType: "07",           # Invoice type
  InvoiceCategory: 1,       # Fixed as 1 for B2C
  InvoiceHeader: "AA",      # Invoice track header
  InvoiceStart: "00000000", # Start number (must end in 00 or 50)
  InvoiceEnd: "00000049"    # End number (must end in 49 or 99)
}

result = client.add_invoice_word_setting(setting_data)

if result[:success]
  puts "Track setting added successfully!"
  puts "Track ID: #{result[:data]['TrackID']}"
else
  puts "Error: #{result[:error]}"
end
```

### Update Invoice Word Status (設定字軌號碼狀態)

```ruby
client = Ecpay::B2CInvoice::Client.new

track_id = "your_track_id"
invoice_status = 2  # 0=Disabled, 1=Paused, 2=Enabled

result = client.update_invoice_word_status(track_id, invoice_status)

if result[:success]
  puts "Track status updated successfully!"
else
  puts "Error: #{result[:error]}"
end
```

### Query Invoice Word Settings (查詢字軌)

```ruby
client = Ecpay::B2CInvoice::Client.new

query_data = {
  MerchantID: "your_merchant_id",
  InvoiceYear: "113",      # Taiwan year format
  InvoiceTerm: 0,          # 0 for all terms, 1-6 for specific term
  UseStatus: 0,            # 0 for all status, 1-6 for specific status
  InvoiceCategory: 4       # Fixed as 4 for query
}

result = client.get_invoice_word_setting(query_data)

if result[:success]
  puts "Track settings found!"
  result[:data]['InvoiceInfo'].each do |track|
    puts "Track: #{track['InvoiceHeader']}, Status: #{track['UseStatus']}"
  end
else
  puts "Error: #{result[:error]}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
