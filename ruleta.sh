#!/bin/bash


#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"



function ctrl_c(){
  echo -e "\n ${redColour}[!] Saliendo....${endColour}"
  tput cnorm && exit 1
}

#Ctrl + c 
trap ctrl_c INT

#Funciones
function helpPanel(){
  
  echo -e "\n${yellowColour}[+] ${endColour} ${grayColour}Uso: ${endColour}\n"
  echo -e "\t ${purpleColour}m) ${grayColour}Dinero con el que se desea jugar${endColour}"
  echo -e "\t ${purpleColour}t) ${grayColour}Técnicas a utilizar ${yellowColour}(martingala/reverselabouchere)${endColour}"
  echo -e "\t ${purpleColour}h) ${grayColour}Mostrar este panel de ayuda${endColour}\n"
  #exit 1
}

function martingala(){
  
  echo -e "\n${yellowColour}[+] ${grayColour}Dinero actual: $money€${grayColour}"
  echo -ne "${yellowColour}[+] ${grayColour}¿Cuánto dinero tienes pensado apostar? ->${grayColour} " && read initial_bet
  echo -ne "${yellowColour}[+]${grayColour} ¿A qué deseas apostar continuameste, ${purpleColour}par ${grayColour}o ${blueColour}impar${grayColour}? -> ${endColour}" && read par_impar

  echo -e "\n\n${yellowColour}[+] ${grayColour}Vamos a jugar con una cantidad inicial de ${greenColour}$initial_bet€ ${grayColour}a ${blueColour}$par_impar${endColour}"
  
  tput civis
  aux_par_impar=$(echo "$par_impar" | tr '[:upper:]' '[:lower:]')
  backup_bet=$initial_bet
  play_counter=1
  max_money=$money
  while true; do
     number=$(($RANDOM % 37))
    echo -e "\n ${purpleColour}[+]${grayColour} El número que ha salido es: ${turquoiseColour}$number${endColour}"
    if [ $money -gt $max_money ]; then max_money=$money ; fi 
    money=$(($money-$initial_bet))
    echo -e "\n ${purpleColour}[+]${grayColour} Acabas de apostar ${redColour}$initial_bet€ ${grayColour}y te quedan ${greenColour}$money€"
    if [ ! $money -le 0 ]; then
      
      if [ $(($number % 2)) -eq 0 ]; then
          
          if [ "$aux_par_impar" == "par" ]; then #hemos indicado que jugamos con par
                if [ $number -eq 0 ]; then 
                  echo -e "\n ${redColour}[-] Perdemos";
                  initial_bet=$(($initial_bet*2)) 
                else 
                #Ganamos y no hacemos nada
                echo -e "\n ${greenColour}[+] Ganamos";
                reward=$(($initial_bet*2))
                money=$(($money+$reward))
                initial_bet=$backup_bet

                fi 
          else #hemos indicado que jugamos con impar 
            #Sale par y juamos con impar -> Perdemos
            initial_bet=$(($initial_bet*2)) 
            echo -e "\n ${redColour}[-] Perdemos";
          fi



      else # sale impar 

          if [ "$aux_par_impar" == "par" ]; then #hemos indicado que jugamos con par
        
              #Sale impar y jugamos con par -> Perdemos
              initial_bet=$(($initial_bet*2))
              echo -e "\n ${redColour}[-]  Perdemos";
          else #hemos indicado que jugamos con impar
              if [ $number -eq 0 ]; then 
                echo -e "\n ${greenColour}[+] Ganamos";reward=$((initial_bet*2));
              else 

                reward=$(($initial_bet*2))
                money=$(($money+$reward))
                initial_bet=$backup_bet
                echo -e "\n ${greenColour}[+] Ganamos";
              fi


          fi  
      fi
      echo -e "\n ${purpleColour}[!]${grayColour} Me quedan ${yellowColour}$money${endColour}"
      echo -e "\n ---------------------------------------------------------------------"
      sleep 3
    
    else
      echo -e "\n ${redColour}[!] Te has quedado sin dinero${endColour}\n"
      echo -e "\n ${yellowColour}[+] ${grayColour}Han habido un total de ${greenColour}$play_counter ${grayColour}jugadas${endColour}"
      echo -e "\n ${greenColour}[€] ${grayColour}Antes de perder he conseguido un máximo de dinero de ${yellowColour}$max_money€${endColour}"
      tput cnorm;
      exit 0
    fi
 let play_counter+=1
done 
  tput cnorm

}

function reverselabouchere(){
  echo -e "reverse"
}
# Indicadores
#
# Vamos a usarlo para ver si el usuario ha hecho uso del parámetro m, en vez de hacerlo en el propio getopts
declare -i parameter_counter=0

while getopts "m:t:h" arg; do
  case $arg in  
  m) money=$OPTARG;;
  t) technique=$OPTARG;;
  h);;
  esac

done


if [ $money ] && [ $technique ]; then
    aux_technique=$(echo "$technique" | tr '[:upper:]' '[:lower:]')
  if [ "$aux_technique" == "martingala" ]; then
      martingala $money
  elif [ "$aux_technique" == "reverselabouchere" ]; then
      reverselabouchere $money
  else 
  echo -e "\n${redColour} [!] La técnica introducida no existe${endColour}"
  helpPanel

  fi

else
 helpPanel 
fi
