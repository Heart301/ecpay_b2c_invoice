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

result = client.create_invoice(invoice_data)

if result[:success]
  puts "Invoice created successfully!"
  puts "Invoice Number: #{result[:data]['InvoiceNo']}"
  puts "Invoice Date: #{result[:data]['InvoiceDate']}"
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
