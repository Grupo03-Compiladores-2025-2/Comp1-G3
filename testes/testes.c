#include <stdio.h>
#include <math.h>

int main(){

    // Imprimir Mensagem

    printf("Testar codigos\n");

    // Atribuir valores inteiros

    int num1, num2, i;

    printf("Digite dois numeros inteiros, o primeiro numero só será valido numero entre 1 e 99 e o segundo diferente de 0, diferente disso os numeros serão mudados.\n");
    scanf("%d", &num1);
    scanf("%d", &num2);


    // Condicionais

    if(num1 == 0 && num2 == 0){
        printf("Realmente tentou dois zeros? Ele será mudado claro.\n");
    }


    if(num2 == 0){
        printf("O segundo numero foi igual a 0, ele será mudado para 10.\n");
        num2 = 10;
    }

    if(num1 >= 100){
        num1 = 99;
        i = 1;
    }

    if(num1 <= 0){
        num1 = 1;
        i = 2;
    }

    if(i == 1 || i == 2){
        printf("O primeiro numero saiu do intervalo aceito, ele sera mudado...\n");
    }


    switch( i ){

    case 1:
        printf("O primeiro numero foi maior que 99, ele será mudado para 99.\n");
        break;
    case 2:
        printf("O primeiro numero foi menor que 1, ele será mudado para 1.\n");
        break;
   }

    if(num1 > num2){
        printf("%d é maior que %d.\n", num1, num2);
    } else if (num1 < num2){
        printf("%d é menor que %d.\n", num1, num2);
    }else {
        printf("%d é igual a %d.\n", num1, num2);
    }




    // Contas com 2 numeros inteiros

    printf("%d\n", num1 + num2);
    printf("%d\n", num1 - num2);
    printf("%d\n", num1 * num2);
    printf("%d\n", num1 / num2);
    printf("%d\n", num1 % num2);
 

    // Repetições

    i = 1;

    while(i < 6){
        printf("%d ", i);
        i++;
    }

    for(i = 5; i > 0; i--){
        printf(" %d", i);    
    }


    do
    {
         printf("\n"); i++;

    } while(i < 3);

    printf("Fim\n");

    return 0;
}