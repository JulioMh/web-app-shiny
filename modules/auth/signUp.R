signUpUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      id = "signup",
      style = "width: 500px; max-width: 100%; margin: 0 auto; padding: 20px;",
      wellPanel(
        h2("SIGN UP", class = "text-center", style = "padding-top: 0;color:#333; font-weight:600;"),
        textInput(
          ns("userName"),
          placeholder = "Username",
          label = tagList(icon("user"), "Username")
        ),
        textInput(
          ns("email"),
          placeholder = "Email",
          label = tagList(icon("envelope"), "Email")
        ),
        passwordInput(
          ns("passwd"),
          placeholder = "Password",
          label = tagList(icon("unlock-alt"), "Password")
        ),
        passwordInput(
          ns("confPasswd"),
          placeholder = "Confirm password",
          label = tagList(icon("unlock-alt"), "Confirm password")
        ),
        textOutput(ns("warning")),
        br(),
        div(
          style = "text-align: center;",
          actionButton(
            ns("signup"),
            "SIGN UP",
            style = "color: white; background-color:#3c8dbc;
                                 padding: 10px 15px; width: 150px; cursor: pointer;
                                 font-size: 18px; font-weight: 600;"
          ),
          br(),
          actionLink(ns("login"), "LOG IN")
        ),
        br(),
        br(),
        textOutput(ns("res")),
        br()
      )
    )
  )
}

signUp <- function(input, output, session) {
  emailRejex <- "^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$"
  passRejex <- "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{6,}$"
  
  observeEvent(input$login, {
    change_page("login")
  })
  
  output$warning <- renderText({
    validate(
      need(input$userName != "", label = "User name"),
      need(str_detect(input$email,regex(emailRejex)), message = "Email isn't correct"),
      need(str_detect(input$passwd,regex(passRejex)), message = "Password must has at least 6 characters, one number, one uppercase and one lowecase"),
      need(input$passwd == input$confPasswd, message = "Passwords must match")
    )
  })
  
  observeEvent(input$signup, isolate({
    if (validateFields(input, emailRejex, passRejex)) {
      data <- list(
        "username" = input$userName,
        "password" = input$passwd,
        "email" = input$email
      )
      res <- performanceSignUp(data)
      output$res <- renderText(res)
    }
  }))
}

validateFields <- function(input, emailRejex, passRejex) {
  res <- TRUE
  if (input$userName == '' ||
      !str_detect(input$email, regex(emailRejex)) ||
      input$confPasswd != input$passwd ||
      !str_detect(input$passwd, regex(passRejex))) {
    res <- FALSE
  }
  return(res)
}

performanceSignUp <- function(data) {
  db <-
    dbConnect(
      MySQL(),
      dbname = databaseName,
      host = options()$mysql$host,
      port = options()$mysql$port,
      user = options()$mysql$user,
      password = options()$mysql$password
    )
  res <- "Welcome!"
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    "User",
    paste(names(data), collapse = ", "),
    paste(data, collapse = "', '")
  )
  tryCatch({
    dbGetQuery(db, query)
  }, error = function(res) {
    res <- "Something went worng"
  })
  dbDisconnect(db)
  return(res)
  
}