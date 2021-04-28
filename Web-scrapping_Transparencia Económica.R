################################################################################################
################################################################################################
############Web scraping pagina Plataforma Transparencia Económica##############################
################################################################################################


#Paquetes
paquetes <- c("xml2", "stringr", "httr","RSelenium")
instalaciones <- paquetes[!paquetes %in% installed.packages()]
for(libs in instalaciones) install.packages(libs)
sapply(paquetes,require,character = T)


#--Perfil del Navegador
referencedirectory <- "D:/CURSO-WEB SCRAPING CON R/"
fprof <- makeFirefoxProfile(list(browser.download.dir = referencedirectory,browser.download.folderList = 2L, browser.download.manager.showWhenStarting = FALSE,
                                 browser.helperApps.neverAsk.saveToDisk="text/plain,text/x-csv,text/csv,application/ms-excel,application/vnd.ms-excel,application/csv,application/x-csv,text/csv,text/comma-separated-values,text/x-comma-separated-values,text/tab-separated-values,application/pdf",browser.tabs.remote.autostart = FALSE,browser.tabs.remote.autostart.2 = FALSE,browser.tabs.remote.desktopbehavior = FALSE))

#Iniciar el firefox
rD <- rsDriver(port = 5113L, browser = "firefox",  iedrver = NULL,
               verbose = TRUE, check = TRUE, extraCapabilities = fprof)

#Obtener acceso al cliente
remDr <- rD[["client"]]
#--Observar el html

remDr$navigate("http://apps5.mineco.gob.pe/transparencia/Navegador/Default.aspx")

html_x <- remDr$findElement("xpath","/html")

html_x$getElementAttribute("outerHTML")

#######################################
#--Descargar archivo por departamento##
#######################################

#Cambiar el url de acuerdo al Frame
remDr$navigate("https://apps5.mineco.gob.pe/transparencia/Navegador/Navegar.aspx")


#Busca en la página el elemnto de departamento 
#//*[@id="ctl00_CPH1_BtnDepartamentoMeta"]
click_nivel_dep <- remDr$findElement("xpath","//input[@name='ctl00$CPH1$BtnDepartamentoMeta']")
#Luego utilizas clic element para realizar un click
click_nivel_dep$clickElement()


#Encontrar los elementos TR
#Panel en donde estan todas las entradas
#//*[@id="PnlData"]
#@class='Data' es la clase que permite ingresar a toda la tabla
# el /tbody me permite ingresar al body de la tabla
#//*[@id="PnlData"]/table[@class='Data']/tbody
# el /tr me permite ingresar a cada fila de departamento
#//*[@id="tr0"]
#Encontramos el elemneto para hacer click /td[1]/input
#/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[1]/td[1]/input
#/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[2]/td[1]/input


rows <- remDr$findElements("xpath","//div[@id='PnlData']//table[@class='Data']/tbody/tr")

count <- length(rows)+1



#Funcion para un tiempo de espera
testit <- function(x)
{
  p1 <- proc.time()
  Sys.sleep(x)
  proc.time() - p1 # The cpu usage should be negligible
}

count2 <- 0 # Declaro una variable para que aumente en cada recorrido
##Loop
for (row in rows)
{
  count2=count2+1
  print(count2)
  
  testit(1)
  #Encontramos el elemento para hacer click /td[1]/input
  #/html/body/form/div[4]/div[3]/div[3]/div/table[2]/tbody/tr[1]/td[1]/input
  sel_ratio <- remDr$findElement("xpath",paste0("//div[@id='PnlData']//table[@class='Data']/tbody/tr[",toString(count2),"]/td[1]/input"))
  
  sel_ratio$clickElement()
  
  #//*[@id="ctl00_CPH1_BtnTipoGobierno"]
  btn_tip_gob <- remDr$findElement("xpath","//*[@id='ctl00_CPH1_BtnTipoGobierno']")
  
  btn_tip_gob$clickElement()
  
  testit(1)
  btn_expor <- remDr$findElement("xpath","//*[@id='ctl00_CPH1_lbtnExportar']")
  
  btn_expor$clickElement()
  
  #Ir a un paso atras
  remDr$goBack()
  testit(1)
  #Nombre de dpto
  #//*[@id="tr0"]/td[2]
  text_depa <- remDr$findElement("xpath",paste0("//div[@id='PnlData']//table[@class='Data']/tbody/tr[",toString(count2),"]/td[2]"))
  
  #Mostrar el texto del elemento
  print(text_depa$getElementText())
  
  #Mostrar la lista de 
  #print(list.files("C:/Users/Computer/Downloads"))
  
}

#Cerrar Conexion
remDr$close()