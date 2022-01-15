require "json"
require "net/http"
require "webrick"

$headers = {
    "Content-Type": "application/json; charset=utf8",
    "Authorization": ARGV[0],
}

$device_id = ARGV[1]

srv = WEBrick::HTTPServer.new({:BindAddress => "0.0.0.0", :Port => 22559})

def post(command)
    Net::HTTP.post(
        uri = URI.parse("https://api.switch-bot.com/v1.0/devices/#{$device_id}/commands"),
        {"command": command}.to_json,
        $headers,
    )
end

class MyServlet < WEBrick::HTTPServlet::AbstractServlet
    def do_POST(req, res)
        case JSON.load(req.body)["event"].to_sym
        when :sleep_tracking_started
            post("turnOff")
        when :sleep_tracking_stopped
            post("turnOn")
        end
    end
end

srv.mount("/", MyServlet)
trap("INT"){ srv.shutdown }
srv.start
