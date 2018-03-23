class WelcomeController < ApplicationController
  def test
    response = HTTParty.get("http://api.wunderground.com/api/#{ENV['wunderground_api_key']}/geolookup/conditions/q/LA/New_Orleans.json")

    @results = {}
    @results[:location] = response['location']['city']
    @results[:temp_f] = response['current_observation']['temp_f']
    @results[:temp_c] = response['current_observation']['temp_c']
    @results[:weather_icon] = response['current_observation']['icon_url']
    @results[:weather_words] = response['current_observation']['weather']
    @results[:forecast_link] = response['current_observation']['forecast_url']
    @results[:real_feel_f] = response['current_observation']['feelslike_f']
  end

  def index
    # Creates an array of states that our user can choose from on our index page
    @states = %w(HI AK CA OR WA ID UT NV AZ NM CO WY MT ND SD NE KS OK
    TX LA AR MO IA MN WI IL IN MI OH KY TN MS AL GA FL SC NC VA WV DE MD PA NY
    NJ CT RI MA VT NH ME DC).sort!

    @results = {}

   # removes spaces from the 2-word city names and replaces the space with an underscore
    if params[:city] != nil
      params[:city].gsub!(" ", "_")
    end
   #checks that the state and city params are not empty before calling the API
   # if params[:state] != "" && params[:city] != "" && params[:state] != nil && params[:city] != nil
    if params[:state].present? && params[:city].present?

     results = HTTParty.get("http://api.wunderground.com/api/#{Figaro.env.wunderground_api_key}/geolookup/conditions/q/#{params[:state]}/#{params[:city]}.json")

     #if no error is returned from the call, we fill our instants variables with the result of the call
     if results['response']['error'] == nil || results['error'] ==""

       #Checks to see if the response contains an array (ambigous response for an invalid city/state combination) or a hash(valid response)
       if results.key?("location")
         @results[:location] = results['location']['city']
         @results[:temp_f] = results['current_observation']['temp_f']
         @results[:temp_c] = results['current_observation']['temp_c']
         @results[:weather_icon] = results['current_observation']['icon_url']
         @results[:weather_words] = results['current_observation']['weather']
         @results[:forecast_link] = results['current_observation']['forecast_url']
         @results[:real_feel_f] = results['current_observation']['feelslike_f']
         @results[:real_feel_c] = results['current_observation']['feelslike_c']
       else
         @error = "City/State combination does not exist."
       end # if results.key?("location")

     else
       # if there is an error, we report it to our user via the @error variable
       @error = results['response']['error']['description']
     end # results['response']['error'] == nil || results['error'] ==""

   end # if params[:state] != "" && params[:city] != "" && params[:state] != nil && params[:city] != nil

  end
end
