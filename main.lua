local json = require("json")
local mime = require("mime")
local commands_json,signInText,usernameText,passwordText,emailText,usernameTxtBox,passwordTxtBox,emailTxtBox,doneButton,pickerWheel,msg,title
local widget = require( "widget" )

APPID = 'my_key'
RESTAPIKEY = 'my_rest_key'

local function displayFeatured(dessert,friendsNum)

    usernameText:removeSelf()
    usernameText = nil
    signInText:removeSelf()
    signInText = nil
    passwordText:removeSelf()
    passwordText = nil
    emailText:removeSelf()
    emailText = nil
    usernameTxtBox:removeSelf()
    usernameTxtBox = nil
    passwordTxtBox:removeSelf()
    passwordTxtBox = nil
    emailTxtBox:removeSelf()
    emailTxtBox = nil
    
    local cupcakeText = display.newText("Welcome to the Dessert-O-Meter!\nThe cupcake of the day is "..dessert..". Guess what, "..friendsNum.." other members like "..dessert.." too!", 10, 350, 300, 400, "GillSans", 20 )
    
    local cupcakeImage = display.newImage( "images/"..dessert..".png" )
    cupcakeImage.x = display.contentWidth/2
    cupcakeImage.y = 200

end

local function init()

    
    local bg = display.newRoundedRect( 0, 0, display.contentWidth,display.contentHeight,3)
    bg:setFillColor(155, 89, 182)--amethyst
    bg.strokeWidth=10
    bg:setStrokeColor(142, 68, 173)--wysteria

    

    --create login
    signInText = display.newText("Register for the Dessert-O-Meter!", 30, 20, 300, 400, "GillSans", 20 )
    
    usernameText = display.newText("Username:", 60, 50, 300, 400, "GillSans", 20 )
    
    usernameTxtBox = native.newTextField( display.contentWidth/2-100, 80, 200, 20)
    
    passwordText = display.newText("Password:", 60, 100, 300, 400, "GillSans", 20 )
    
    passwordTxtBox = native.newTextField( display.contentWidth/2-100, 130, 200, 20)
    
    passwordTxtBox.isSecure=true
    
    emailText = display.newText("Email:", 60, 150, 300, 400, "GillSans", 20 )
    
    emailTxtBox = native.newTextField( display.contentWidth/2-100, 180, 200, 20)
    
    

    local function onSelectFlavorButtonRelease()

        local columnData = 
        { 
            { 
                align = "center",
                width = display.contentWidth,
                startIndex = 1,
                labels = 
                {
                    "","chocolate", "watermelon", "rainbow"
                },
            }
        }

       pickerWheel = widget.newPickerWheel
        {
            top = display.contentHeight-220,
            font = native.systemFontBold,
            columns = columnData
        }

        local function onDoneButtonRelease(event)

            if event.phase == "ended" then

                local pickerValues = pickerWheel:getValues()
                flavorIndex = pickerValues[1].value

                print(flavorIndex)
                                
                    
                    display.remove( pickerWheel )
                    pickerWheel = nil
                       
                    display.remove( doneButton )
                    doneButton = nil

            end

        end

        doneButton = widget.newButton
            {
                defaultFile = "images/btnClose.png",
                overFile="images/btnClose.png",
                onRelease = onDoneButtonRelease,
                width=29,
                height=17,
                font = "GillSans",
                labelColor = {
                  default = { 255, 255, 255 },
                  over = { 120, 53, 128, 255 },
                }

            }
    
            doneButton.x = display.contentWidth/2
            doneButton.y = display.contentHeight-200
        end


       local selectFlavorButton = widget.newButton
        {
            label = "My Favorite Flavor",
            id = "btnSelectFlavor",
            width = 170,
            height = 20,
            onRelease = onSelectFlavorButtonRelease,
            font = "GillSans"

        }
        selectFlavorButton.x = display.contentWidth/2
        selectFlavorButton.y = 230

     local function emailClient(email)
        
        local function emailSent(event)
            if event.phase == "ended" then
                local response = event.response
                print(response)
            end
        end
        
        headers = {}
        headers["X-Parse-Application-Id"] = APPID
        headers["X-Parse-REST-API-Key"] = RESTAPIKEY
        headers["Content-Type"] = "application/json"


        local params = {}

        commands_json =
             {
                ["email"] = email
             }        
 
        postData = json.encode(commands_json)
        
        local params = {}
        params.headers = headers
        params.body = postData

        
        network.request( "https://api.parse.com/1/functions/sendEmail","POST",emailSent,params)   
        
       
    end


    local function onSaveButtonRelease()

        print(usernameTxtBox.text,passwordTxtBox.text,emailTxtBox.text,flavorIndex)

        --register new user

        local function registerNewUser(event)
            
            if event.phase == "ended" then
                local response = event.response
                print(response)
                local t = json.decode(response)
                

                if t.error ~= nil then
                    title = "Oops!"
                    msg = t.error
                else
                    title = "Success!"
                    msg = "You're now a registered user of the Dessert-O-Meter!"
                
                    --get featured dessert
                    local function getFeatured(event)

                          if event.phase == "ended" then

                            local response = event.response
                            local decodedResponse = json.decode(response)
                            local dessert = decodedResponse.result
                            print(dessert[1].favorite)
                            print(#dessert)
                            emailClient(emailTxtBox.text)
                            displayFeatured(dessert[1].favorite,#dessert)
                          
                          end
        
                    end
   
                    headers = {}
                    headers["X-Parse-Application-Id"] = APPID
                    headers["X-Parse-REST-API-Key"] = RESTAPIKEY
                    headers["Content-Type"] = "application/json"


                    local params = {}

                    commands_json =
                         {
                            [""] = ""
                         }        
             
                    postData = json.encode(commands_json)
                    
                    local params = {}
                    params.headers = headers
                    params.body = postData

                    network.request( "https://api.parse.com/1/functions/getFeatured","POST",getFeatured,params)   
               
                end
                
                local alert = native.showAlert( "", msg, {"OK"}, onComplete )
 
            end
        end
            
            headers = {}
            headers["X-Parse-Application-Id"] = APPID
            headers["X-Parse-REST-API-Key"] = RESTAPIKEY
            headers["Content-Type"] = "application/json"


        local params = {}

                commands_json =
                     {
                        ["email"] = emailTxtBox.text,
                        ["password"] = passwordTxtBox.text,
                        ["username"] = usernameTxtBox.text,
                        ["favorite"] = flavorIndex

                     }        
         
                postData = json.encode(commands_json)
                
                local params = {}
                params.headers = headers
                params.body = postData

        network.request( "https://api.parse.com/1/users","POST",registerNewUser,params)   

    end
  
 
     local saveButton = widget.newButton
        {
            label = "Save",
            id = "btnSave",
            width=80,
            height=20,
            onRelease = onSaveButtonRelease,
            font = "GillSans"

        }
        saveButton.x = display.contentWidth/2
        saveButton.y = 290


        
    end 

init()





