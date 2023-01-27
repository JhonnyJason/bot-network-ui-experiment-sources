############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("secretmanagersettingsmodule")
#endregion

############################################################
import M from "mustache"

############################################################
import * as cfg from "./configmodule.js"
import * as S from "./statemodule.js"

############################################################
allOptions = []
choiceIndex = 0

############################################################
optionsTemplate = '''
    {{#options}}
    <option value="{{index}}" {{#isSelected}}selected{{/isSelected}}>
        {{url}}
    </option>
    {{/options}}

'''

############################################################
export initialize = ->
    log "initialize"
    # options and choice from Config
    options = cfg.secretManagerOptions
    allOptions.push(option) for option in options
    choiceIndex = cfg.defaultSecretManagerChoice

    # user defined options
    customOptions = S.load("customSecretManagerOptions")
    if Array.isArray(customOptions) and customOptions.length > 0 
        allOptions.push(option) for option in options
    
    # the actual user choice
    userChoice = S.load("secretManagerChoice")
    if typeof userChoice == "number" and userChoice >= 0 and userChoice < allOptions.length
        choiceIndex = userChoice

    cObj = {options:[]}
    for url,index in allOptions
        isSelected = index == choiceIndex 
        cObj.options.push({index, url, isSelected})
    
    # set up UI with user allOptions and our choiceIndex
    optionsHTML = M.render(optionsTemplate, cObj)
    secretmanagerOptions.innerHTML = optionsHTML
    
    # react on change
    secretmanagerOptions.addEventListener("change", choiceChanged)
    return

############################################################
choiceChanged = ->
    # log "choiceChanged"
    choiceIndex = parseInt(secretmanagerOptions.value)
    # log "choiceIndex: #{choiceIndex}"
    S.save("secretManagerChoice", choiceIndex)
    return