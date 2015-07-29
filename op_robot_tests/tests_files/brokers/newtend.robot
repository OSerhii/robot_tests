*** Setting ***
Library  Selenium2Screenshots
Library  String
Library  DateTime

*** Variables ***
${locator.tenderId}                  jquery=h3

*** Keywords ***
Підготувати дані для оголошення тендера
  ${INITIAL_TENDER_DATA}=  prepare_test_tender_data
  [return]   ${INITIAL_TENDER_DATA}

Підготувати клієнт для користувача
  [Arguments]  @{ARGUMENTS}
  [Documentation]  Відкрити брaвзер, створити обєкт api wrapper, тощо
  ...      ${ARGUMENTS[0]} ==  username

  Open Browser   ${BROKERS['${USERS.users['${username}'].broker}'].url}   ${USERS.users['${username}'].browser}   alias=${ARGUMENTS[0]}
  Set Window Size   @{USERS.users['${ARGUMENTS[0]}'].size}
  Set Window Position   @{USERS.users['${ARGUMENTS[0]}'].position}
  Wait Until Page Contains Element   id=indexpage_login   100
  Click Element   id=indexpage_login
  Wait Until Page Contains Element   id=password   100
  Input text   id=login-email   ${USERS.users['${username}'].login}
  Input text   id=password   ${USERS.users['${username}'].password}
  Click Element   id=submit-login-button
  Wait Until Page Contains Element   xpath=//div[@class="introjs-overlay"]   100


Створити тендер
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tender_data
## Inicialisation
  ${items}=         Get From Dictionary   ${ARGUMENTS[1].data}               items
  ${title}=         Get From Dictionary   ${ARGUMENTS[1].data}               title
  ${description}=   Get From Dictionary   ${ARGUMENTS[1].data}               description
  ${budget}=        Get From Dictionary   ${ARGUMENTS[1].data.value}         amount
  ${step_rate}=     Get From Dictionary   ${ARGUMENTS[1].data.minimalStep}   amount

  ${items_description}=   Get From Dictionary   ${items[0]}                          description
  ${quantity}=      Get From Dictionary   ${items[0]}                                quantity
  ${cpv}=           Get From Dictionary   ${items[0].classification}                 description_ua
  ${dkpp_desc}=     Get From Dictionary   ${items[0].additionalClassifications[0]}   description
  ${dkpp_id}=       Get From Dictionary   ${items[0].additionalClassifications[0]}   id
  ${unit}=          Get From Dictionary   ${items[0].unit}                           name

  ${start_date}=           Get From Dictionary   ${ARGUMENTS[1].data.tenderPeriod}    startDate
  ${end_date}=             Get From Dictionary   ${ARGUMENTS[1].data.tenderPeriod}    endDate
  ${enquiry_start_date}=   Get From Dictionary   ${ARGUMENTS[1].data.enquiryPeriod}   startDate
  ${enquiry_end_date}=     Get From Dictionary   ${ARGUMENTS[1].data.enquiryPeriod}   endDate
  ${deliverydate_end_date}=   Get From Dictionary   ${items[0].deliveryDate}          endDate

  ${countryName}=     Get From Dictionary   ${items[0].deliveryAddress}   countryName
  ${ZIP}=             Get From Dictionary   ${items[0].deliveryAddress}   postalCode
  ${region}=          Get From Dictionary   ${items[0].deliveryAddress}   region
  ${locality}=        Get From Dictionary   ${items[0].deliveryAddress}   locality
  ${streetAddress}=   Get From Dictionary   ${items[0].deliveryAddress}   streetAddress
##
  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  Go To                              ${USERS.users['${username}'].homepage}
  Wait Until Page Contains Element   xpath=//a[@href="#/create-tender"]   100
  Click Link                         xpath=//a[@href="#/create-tender"]
  Wait Until Page Contains           Новый тендер    100
# Input fields tender
  Input text   name=tenderName       ${title}
  Input text   name=tenderDescription            ${description}
  Input text   id=budget             ${budget}
  Click Element                      id=with-nds
  Input text   id=step               ${step_rate}
## 1-st Item ifo
  Input text   id=itemDescription0   ${items_description}
  Input text   id=quantity0          ${quantity}
  Click Element                      xpath=//a[@class="dropdown-toggle ng-binding"]
  Click Element                      xpath=//a[contains(text(),'${unit}')]
# Set CPV
  Click Element                      id=classifier10
  Wait Until Page Contains Element   xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   100
  Input text                         xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   ${cpv}
  Wait Until Page Contains Element   xpath=//span[contains(text(),'${cpv}')]   20
  Click Element                      xpath=//input[@class="ng-pristine ng-untouched ng-valid"]
  Click Element                      xpath=//button[@class="btn btn-default btn-lg pull-right choose ng-binding"]
# Set ДКПП
  Click Element                      id=classifier20
  Wait Until Page Contains Element   xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   100
  Input text                         xpath=//input[@class="ng-pristine ng-untouched ng-valid"]   ${dkpp_desc}
  Wait Until Page Contains Element   xpath=//span[contains(text(),'${dkpp_id}')]   100
  Click Element                      xpath=//span[contains(text(),'${dkpp_id}')]/../..//input[@class="ng-pristine ng-untouched ng-valid"]
  Click Element                      xpath=//button[@class="btn btn-default btn-lg pull-right choose ng-binding"]
# Set Delivery Address
  Click Element                      id=deliveryAddress0
  Wait Until Page Contains Element   xpath=//input[1][@class="form-control ng-pristine ng-untouched ng-valid"]   100
  Input text                         xpath=//input[1][@class="form-control ng-pristine ng-untouched ng-valid"]   ${countryName}
  Input text                         xpath=//input[1][@class="form-control ng-pristine ng-untouched ng-valid"]   ${ZIP}
  Input text                         xpath=//input[1][@class="form-control ng-pristine ng-untouched ng-valid"]   ${region}
  Input text                         xpath=//input[1][@class="form-control ng-pristine ng-untouched ng-valid"]   ${locality}
  Input text                         xpath=//input[1][@class="form-control ng-pristine ng-untouched ng-valid"]   ${streetAddress}
  Click Element                      xpath=//button[@class="btn btn-lg single-btn ng-binding"]
# Set Item Datetime
  Set datetime   end-date-delivery0         ${deliverydate_end_date}
##
# Set tender datatimes
  Set datetime   start-date-registration    ${start_date}
  Set datetime   end-date-registration      ${end_date}
  Set datetime   end-date-qualification     ${enquiry_end_date}
  Set datetime   start-date-qualification   ${enquiry_start_date}

  Run Keyword If    '${mode}' == 'multi'     Додати придмет   items

  Click Element                      xpath=//button[@class="btn btn-lg btn-default cancel pull-right ng-binding"]
  Wait Until Page Contains Element   xpath=//div[@ng-click="goHome()"]   30
  Click Element                      xpath=//div[@ng-click="goHome()"]
###  harcode Idis bacause issues on the Newtend side, to remove after fix:
  ${tender_UAid}=   Convert To String   UA-2015-07-06-000105
###  ${tender_UAid}=  Get Text  xpath=//div[@class="title"]
  ${Ids}   Create List    ${tender_UAid}
  [return]  ${Ids}

Set datetime
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  control_id
  ...      ${ARGUMENTS[1]} ==  date
#Pick Date
  Click Element                      xpath=//input[@id="${ARGUMENTS[0]}"]/../span[@class="calendar-btn"]
  Wait Until Page Contains Element   xpath=//td[@class="text-center ng-scope"]   30
  ${datapicker_id}=   Get Element Attribute   xpath=//input[@id="${ARGUMENTS[0]}"]/..//td[@class="text-center ng-scope"]@id
  ${datapicker_id}=   Get Substring   ${datapicker_id}   0   -1
  ${date_index}=   newtend_date_picker_index   ${ARGUMENTS[1]}
  ${datapicker_id}=   Convert To String   ${datapicker_id}${date_index}
  Click Element                      xpath=//input[@id="${ARGUMENTS[0]}"]/..//td[@id="${datapicker_id}"]/button
#Set time
  ${hous}=   Get Substring   ${ARGUMENTS[1]}   11   13
  ${minutes}=   Get Substring   ${ARGUMENTS[1]}   14   16
  Input text   xpath=//input[@id="${ARGUMENTS[0]}"]/../..//input[@ng-model="hours"]   ${hous}
  Input text   xpath=//input[@id="${ARGUMENTS[0]}"]/../..//input[@ng-model="minutes"]   ${minutes}


Додати придмет
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  items

## Get values

  Click Element   xpath=//a[@class="icon-black plus-black remove-field ng-scope"]

  Debug


<a class="icon-black plus-black remove-field ng-scope" href="" ng-if="$index == tender.items.length - 1" ng-click="addField()" title="Добавить лот"></a>









#### Not reworked for Newtend ####

Oтримати internal id по UAid
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderid
  etender.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  ${current_location}=   Get Location
  ${tender_id}=   Fetch From Right   ${current_location}   /
###  harcode Idis bacause issues on the E-tender side, to remove, 1 line:
  ${tender_id}=     Convert To String   94ffe180019d459787aafe290cd300e2
  log  ${internal_id}
  [return]  ${internal_id}

Пошук тендера по ідентифікатору
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId

  Switch browser   ${ARGUMENTS[0]}
   Go to   ${BROKERS['${USERS.users['${username}'].broker}'].url}
  Wait Until Page Contains   Список закупівель    10
   sleep  1
   Input Text  jquery=input[ng-change='search()']  ${ARGUMENTS[1]}
   Click Link  jquery=a[ng-click='search()']
   sleep  2
  Click Link    jquery=a[href^="#/tenderDetailes"]
  Wait Until Page Contains    ${ARGUMENTS[1]}   10
  sleep  1
  Capture Page Screenshot

обновити сторінку з тендером
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  tenderId
  ...      ${ARGUMENTS[2]} ==  id
  ${current_location}=   Get Location
  Run keyword if   '${BROKERS['${USERS.users['${username}'].broker}'].url}/#/tenderDetailes/${ARGUMENTS[2]}'=='${current_location}'  Reload Page
  Run keyword unless   '${BROKERS['${USERS.users['${username}'].broker}'].url}/#/tenderDetailes/${ARGUMENTS[2]}'=='${current_location}'  Пошук тендера по ідентифікатору   @{ARGUMENTS}
  Wait Until Page Contains    ${ARGUMENTS[1]}   10
  sleep  1

отримати інформацію із тендера
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  fieldname
  Switch browser   ${ARGUMENTS[0]}
  ${return_value}=  run keyword  отримати інформацію про ${ARGUMENTS[1]}
  [return]  ${return_value}

Відмітити на сторінці поле з тендера
  [Arguments]   ${fieldname}  ${locator}
  ${last_note_id}=  Add pointy note   ${locator}   Found ${fieldname}   width=200  position=bottom
  Align elements horizontally    ${locator}   ${last_note_id}
  sleep  1
  Remove element   ${last_note_id}

Отримати тест із поля і показати на сторінці
  [Arguments]   ${fieldname}
  sleep  3
#  відмітити на сторінці поле з тендера   ${fieldname}   ${locator.${fieldname}}
  ${return_value}=   Get Text  ${locator.${fieldname}}
  [return]  ${return_value}

отримати інформацію про tenderId
  ${return_value}=   Отримати тест із поля і показати на сторінці   tenderId
  [return]  ${return_value.split(' ')[1]}

отримати інформацію про title
  ${return_value}=   Отримати тест із поля і показати на сторінці   title
  [return]  ${return_value}

отримати інформацію про description
  ${return_value}=   Отримати тест із поля і показати на сторінці   description
  [return]  ${return_value}

отримати інформацію про minimalStep.amount
  ${return_value}=   Отримати тест із поля і показати на сторінці   minimalStep.amount
  ${return_value}=   Convert To Number   ${return_value.split(' ')[0]}
  [return]  ${return_value}

отримати інформацію про procuringEntity.name
  ${return_value}=   Отримати тест із поля і показати на сторінці   procuringEntity.name
  [return]  ${return_value}


отримати інформацію про value.amount
  ${return_value}=   Отримати тест із поля і показати на сторінці  value.amount
  ${return_value}=   Evaluate   "".join("${return_value}".split(' ')[:-3])
  ${return_value}=   Convert To Number   ${return_value}
  [return]  ${return_value}

отримати інформацію про tenderPeriod.startDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  tenderPeriod.startDate
  [return]  ${return_value}

отримати інформацію про tenderPeriod.endDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  tenderPeriod.endDate
  [return]  ${return_value}

отримати інформацію про enquiryPeriod.startDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  enquiryPeriod.startDate
  [return]  ${return_value}

отримати інформацію про enquiryPeriod.endDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  enquiryPeriod.endDate
  [return]  ${return_value}


отримати інформацію про items[${item_id}].description
  відмітити на сторінці поле з тендера   items[${item_id}].description   jquery=tender-subject-info.ng-isolate-scope>div.row:contains("Детальний опис предмету закупівлі:")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-subject-info.ng-isolate-scope>div.row:contains("Детальний опис предмету закупівлі:")>:eq(1)>
  [return]  ${return_value}

отримати інформацію про items[${item_id}].quantity
  відмітити на сторінці поле з тендера   items[${item_id}].quantity   jquery=tender-subject-info.ng-isolate-scope>div.row:contains("Кількість:")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-subject-info.ng-isolate-scope>div.row:contains("Кількість:")>:eq(1)>
  ${return_value}=  Convert To Number   ${return_value}
  [return]  ${return_value}

отримати інформацію про items[${item_id}].classification.id
  відмітити на сторінці поле з тендера   items[0].classification.id   jquery=tender-subject-info>div.row:contains("Класифікатор CPV:")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-subject-info>div.row:contains("Класифікатор CPV:")>:eq(1)>
  [return]  ${return_value.split(' ')[0]}

отримати інформацію про items[${item_id}].classification.scheme
  відмітити на сторінці поле з тендера   items[0].classification.id   jquery=tender-subject-info>div.row:contains("CPV")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-subject-info>div.row:contains("CPV")>:eq(1)>
  [return]  ${return_value.split(' ')[0]}

отримати інформацію про items[${item_id}].classification.description
  відмітити на сторінці поле з тендера   classification.description   jquery=tender-subject-info>div.row:contains("Класифікатор CPV:")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-subject-info>div.row:contains("Класифікатор CPV:")>:eq(1)>
  ${return_value}=   catenate  @{return_value.split(' ')[1:]}
  [return]  ${return_value}

отримати інформацію про items[${item_id}].deliveryAddress
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[${item_id}].deliveryAddress
  [return]  ${return_value}

отримати інформацію про items[${item_id}].deliveryDate
  ${return_value}=   Отримати тест із поля і показати на сторінці  items[${item_id}].deliveryDate
  [return]  ${return_value}

отримати інформацію про questions[${question_id}].title
  відмітити на сторінці поле з тендера   questions title   jquery=tender-questions>div:eq(1)>div.row:contains("Тема:")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-questions>div:eq(1)>div.row:contains("Тема:")>:eq(1)>
  [return]  ${return_value}

отримати інформацію про questions[${question_id}].description
  відмітити на сторінці поле з тендера   questions description   jquery=tender-questions>div:eq(1)>div.row:contains("Питання:")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-questions>div:eq(1)>div.row:contains("Питання:")>:eq(1)>
  [return]  ${return_value}

отримати інформацію про questions[${question_id}].date
  відмітити на сторінці поле з тендера   question date   jquery=tender-questions>div:eq(1)>div.row:contains("Дата:")>:eq(1)>
  ${return_value}=   Get Text  jquery=tender-questions>div:eq(1)>div.row:contains("Дата:")>:eq(1)>
  [return]  ${return_value}

отримати інформацію про questions[${question_id}].answer
  відмітити на сторінці поле з тендера   question answer   jquery=tender-questions>div:eq(1)>div:last>
  ${return_value}=   Get Text  jquery=tender-questions>div:eq(1)>div:last>
  [return]  ${return_value}

Подати цінову пропозицію
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} ==  username
  ...      ${ARGUMENTS[1]} ==  ${INTERNAL_TENDER_ID}
  ...      ${ARGUMENTS[2]} ==  test_bid_data

  ${bid}=        Get From Dictionary   ${ARGUMENTS[2].data.value}         amount
  etender.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}
  Wait Until Page Contains          Інформація про процедуру закупівлі    100
  Wait Until Page Contains Element          id=amount   10
  Input text    id=amount                  ${bid}
  Click Element                     xpath=//button[contains(@class, 'btn btn-success')][./text()='Реєстрація пропозиції']

Задати питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${INTERNAL_TENDER_ID}
  ...      ${ARGUMENTS[2]} = question_data

  ${title}=        Get From Dictionary  ${ARGUMENTS[2].data}  title
  ${description}=  Get From Dictionary  ${ARGUMENTS[2].data}  description

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  etender.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}   ${TENDER_ID}

  Wait Until Page Contains Element   jquery=a[href^="#/addQuestion/"]   100
  Click Element                      jquery=a[href^="#/addQuestion/"]
  Wait Until Page Contains Element   id=title
  Input text                         id=title                 ${title}
  Input text                         id=description           ${description}
  Click Element                      xpath=//div[contains(@class, 'form-actions')]//button[@type='submit']

Відповісти на питання
  [Arguments]  @{ARGUMENTS}
  [Documentation]
  ...      ${ARGUMENTS[0]} = username
  ...      ${ARGUMENTS[1]} = ${INTERNAL_TENDER_ID}
  ...      ${ARGUMENTS[2]} = 0
  ...      ${ARGUMENTS[3]} = answer_data

  ${answer}=     Get From Dictionary  ${ARGUMENTS[3].data}  answer

  Selenium2Library.Switch Browser    ${ARGUMENTS[0]}
  etender.Пошук тендера по ідентифікатору   ${ARGUMENTS[0]}   ${ARGUMENTS[1]}   ${TENDER_ID}

  Click Element                      xpath=//div[div/pre[1]]/div[1]
  Input text                         xpath=//div[textarea]/textarea            ${answer}
  Click Element                      xpath=//div[textarea]/span/button[1]
