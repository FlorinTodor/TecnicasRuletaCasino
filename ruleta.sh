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

  declare -i chivato_win=0
  declare -i chivato_lose=0
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
                  chivato_lose=1
                  
                else 
                #Ganamos y no hacemos nada
                  echo -e "\n ${greenColour}[+] Ganamos";
                  chivato_win=1
                fi 
          else #hemos indicado que jugamos con impar 
            #Sale par y juamos con impar -> Perdemos
          
            echo -e "\n ${redColour}[-] Perdemos";
            chivato_lose=1
          fi



      else # sale impar 

          if [ "$aux_par_impar" == "par" ] && [ $number -ne 0]; then #hemos indicado que jugamos con par
              #Sale impar y jugamos con par -> Perdemos
              echo -e "\n ${redColour}[-]  Perdemos";
              chivato_lose=1
          else #hemos indicado que jugamos con impar y consideramos el 0 como impar
                echo -e "\n ${greenColour}[+] Ganamos";
                chivato_win=1
              

          fi  
      fi
      echo -e "\n ${purpleColour}[!]${grayColour} Me quedan ${yellowColour}$money${endColour}"
      echo -e "\n ---------------------------------------------------------------------"
     # sleep 3
    
    else
      echo -e "\n ${redColour}[!] Te has quedado sin dinero${endColour}\n"
      echo -e "\n ${yellowColour}[+] ${grayColour}Han habido un total de ${greenColour}$play_counter ${grayColour}jugadas${endColour}"
      echo -e "\n ${greenColour}[€] ${grayColour}Antes de perder he conseguido un máximo de dinero de ${yellowColour}$max_money€${endColour}"
      tput cnorm;
      exit 0
    fi
  let play_counter+=1

  if [ $chivato_win -eq 1 ];then 

      reward=$(($initial_bet*2))
      money=$(($money+$reward))
      initial_bet=$backup_bet
      chivato_win=0

  elif [ $chivato_lose -eq 1 ]; then
      initial_bet=$(($initial_bet*2))
      chivato_lose=0
  fi



done 
  tput cnorm

}






function inverselabouchere(){
  
  echo -e "\n${yellowColour}[+] ${grayColour}Dinero actual: $money€${grayColour}"
  echo -ne "${yellowColour}[+] ${grayColour}¿A qué deseas apostar continuameste, ${purpleColour}par ${grayColour} o ${blueColour}impar${grayColour} ? -> ${endColour}" && read par_impar
  tput civis
    
   # Declarar el array
  declare -a myArray=()

  # Solicitar la secuencia de números
  echo -ne "\n${yellowColour}[+] ${grayColour}Indica la secuencia de números (separados por espacio) con la que quieres comenzar ${greenColour}-> ${endColour}"
  read -a myArray

  declare -a initial_sequence=(${myArray[@]})
  #echo -e "\n Secuencia inicial: ${initial_sequence[@]}"
  # Mostrar el array ingresado
  echo -e "\n${yellowColour}[+] ${grayColour}Secuencia deseada para las próximas jugadas: [${purpleColour}${myArray[@]}${grayColour}]${endColour}"

  # Verificar que el array tiene al menos dos elementos
  if [ ${#myArray[@]} -ge 2 ]; then
      # Sumar el primer y último elemento del array
      initial_bet=$((myArray[0] + myArray[-1]))
      echo -e "\n${greenColour}[€] ${grayColour}Comenzamos invirtiendo ${greenColour}$initial_bet€${endColour}" 
      bet_to_renew=$(($money+50)) #Dinero el cual una vez alcanzado hará que renovemos a la secuencia initial_bet
      echo -e "\n${greenColour}[€] ${grayColour}El tope a renover la secuencia está establecido en ${yellowColour}$bet_to_renew€"   
      echo -e "\n ---------------------------------------------------------------------"
  else
      echo -e "\n${redColour}[!] El array debe contener al menos dos elementos.${endColour}"
      tput cnorm && exit 1
  fi


  aux_par_impar=$(echo "$par_impar" | tr '[:upper:]' '[:lower:]')
  backup_bet=$initial_bet
  play_counter=1
  max_money=$money

  #Chivatos
  declare -i chivato_win=0;
  declare -i chivato_lose=0;
  
  function reset(){
          Array=(${initial_sequence[@]})
          myArray=(${Array[@]})
          echo -e "\n${yellowColour}[+] ${grayColour}Restablecemos la secuencia a la secuencia inicial: ${greenColour}${myArray[@]}${endColour}"

  }
  function mostrar(){
    echo -e "\n${purpleColour}[!]${grayColour} Me quedan (tras esta apuesta): ${yellowColour}$money${endColour}"
    echo -e "\n ---------------------------------------------------------------------"

  }

  function newbet(){
    Array=("$@")
    declare -i initial_bet=0;
      if [ ${#Array[@]} -eq 1 ]; then #Si el total de elementos en el array es igual que 1
            initial_bet_return=${Array[0]}
      elif [ ${#Array[@]} -eq 0 ]; then
            Array=(${initial_sequence[@]});
            initial_bet_return=$((Array[0] + Array[-1]))
            echo -e "\n${yellowColour}[+] ${grayColour}Restablecemos la secuencia a la secuencia inicial: ${greenColour}${Array[@]}${endColour}"
            myArray=(${Array[@]})
            
      else  
           initial_bet_return=$((Array[0] + Array[-1]))
      fi
  }

  
  while true; do
    sleep 2
      number=$(($RANDOM % 37))
      echo -e "\n${purpleColour}[+]${grayColour} El número que ha salido es: ${turquoiseColour}$number${endColour}"
      if [ $money -gt $max_money ]; then max_money=$money ; fi 
      money=$(($money-$initial_bet))
      echo -e "\n${purpleColour}[+]${grayColour} Acabas de apostar ${redColour}$initial_bet€ ${grayColour}y te quedan ${greenColour}$money€"
      if [ ! $money -le 0 ]; then
        if [ $money -gt $bet_to_renew ]; then
          bet_to_renew+=50
          echo -e "\n${greenColour}[€] ${grayColour}El tope a renover la secuencia está establecido en ${yellowColour}$bet_to_renew€"
        fi
        if [ $(($number % 2)) -eq 0 ]; then
            
            if [ "$aux_par_impar" == "par" ]; then #hemos indicado que jugamos con par
                  if [ $number -eq 0 ]; then 
                    echo -e "\n${redColour}[-] Perdemos";
                    chivato_lose=1;
                     
                  else 
                  #Ganamos 
                  echo -e "\n${greenColour}[+] Ganamos";
                    chivato_win=1
                  fi 
            else #hemos indicado que jugamos con impar 
              #Sale par y juamos con impar -> Perdemos
               
              echo -e "\n${redColour}[-] Perdemos";
              chivato_lose=1
            fi



        else # sale impar 

            if [ "$aux_par_impar" == "par" ] && [ $number -ne 0 ]; then #hemos indicado que jugamos con par
          
                #Sale impar y jugamos con par -> Perdemos
                echo -e "\n${redColour}[-] Perdemos";
                chivato_lose=1

            else #hemos indicado que jugamos con impar y hemos considerado el 0 como impar
                  echo -e "\n${greenColour}[+] Ganamos";
                  chivato_win=1                 
            fi
             
        fi
              
      else
        echo -e "\n${redColour}[!] Te has quedado sin dinero${endColour}\n"
        echo -e "\n${yellowColour}[+] ${grayColour}Han habido un total de ${greenColour}$play_counter ${grayColour}jugadas${endColour}"
        echo -e "\n${greenColour}[€] ${grayColour}Antes de perder he conseguido un máximo de dinero de ${yellowColour}$max_money€${endColour}"
        tput cnorm;
        exit 0
      fi
      let play_counter+=1
  
      if [ $chivato_win -eq 1 ];then 
          reward=$(($initial_bet*2))
          money=$(($money+$reward))
          myArray+=($initial_bet)
          echo -e "\n${yellowColour}[+]${grayColour} Nueva secuencia: ${greenColour}${myArray[@]}${endColour}"
          
        newbet "${myArray[@]}"  
        initial_bet=$initial_bet_return
         
          chivato_win=0
          mostrar 

      elif [ $chivato_lose -eq 1 ]; then

        if [ ${#myArray[@]} -eq 0 ]; then
           reset 
         elif [ ${#myArray[@]} -eq 1 ]; then
              myArray=() #Array vacio para que luego entre en el -eq 0 si volvemos a perder
              #echo -e "\n${redColour}[-]${grayColour} Nueva secuencia: ${redColour}Secuencia Vacía${endColour}"
        else 
            unset myArray[0]
            unset myArray[-1]
            myArray=(${myArray[@]})
            if [ ${#myArray[@]} -eq 0 ]; then
            echo -e "\n${redColour}[-]${grayColour} Nueva secuencia: ${redColour}Secuencia Vacía${endColour}"
            #reset
           
            else
            echo -e "\n${redColour}[-]${grayColour}Nueva secuencia: ${redColour}${myArray[@]}${endColour}"

            fi
        fi
        newbet "${myArray[@]}"  
        initial_bet=$initial_bet_return
        chivato_lose=0
        mostrar
      fi

  done
  
  tput cnorm

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
  elif [ "$aux_technique" == "inverselabouchere" ]; then
      inverselabouchere $money
  else 
  echo -e "\n${redColour} [!] La técnica introducida no existe${endColour}"
  helpPanel

  fi

else
 helpPanel 
fi
