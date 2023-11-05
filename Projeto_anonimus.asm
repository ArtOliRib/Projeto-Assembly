.686
.model flat, stdcall
option casemap :none


include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib



.data

;-------valores de iniciaAção do writeConsole e ReadConsole------


    bufferSize = 256
    bytesRead dd 0
    bytesWritten dd 0
    handleSTDIN dd 0
    handleSTDOUT dd 0
    

;-------ValorR salvo do handle do arquivo aberto ----------------


    inputFileHandle dd 0
    outputFileHandle dd 0


;-------Variaveis do nome do arquivo q sera abertTo--------------  
  

    bufferInputNome db 256 dup(0)
    promptInput db "Digite uma string: ", 0


;-------Variaveis das coordenadas X e Y da imagem---------------


    coordX dd 0
    promptX db "Digite a coordenada x: ", 0

    coordY dd 0
    promptY db "Digite a coordenada Y: ", 0
    

;-------Variaveis de largura e altura da imagem-----------------


    largura dd 0
    promptLargura db "Digite a largura: ", 0

    altura dd 0
    promptAltura db "Digite a altura: ", 0
    

;-------Variaveis do nome do arquivo que vai ser criado---------


    bufferOutputName db 265 dup(0)
    promptOutputName db "Digite o nome do arquivo de saida: ", 0
    


;-------Array dos bytes do arquivo-----------------------------


    fileBuffer db 6480 dup(0)
    readCount dd 0
    writeCount dd 0

    larguraImagem dd 0
    

;-------- Variavel auxiliar dos desvios condicionais -----------

    contador dd 0


      
    
.code

start:
;-------- Leitura do nome do arquivo q vai ser aberto -----------

    
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov handleSTDIN, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov handleSTDOUT, eax


    invoke WriteConsole, handleSTDOUT, addr promptInput, sizeof promptInput, addr bytesWritten, 0

    invoke ReadConsole, handleSTDIN, addr bufferInputNome, bufferSize, addr bytesRead, 0
    

    
;----------Leitura das coordenadas X e Y-------------------------------------------------------


    invoke WriteConsole, handleSTDOUT, addr promptX, sizeof promptX, addr bytesWritten, 0

    invoke ReadConsole, handleSTDIN, addr coordX, bufferSize, addr bytesRead, 0

    
    invoke WriteConsole, handleSTDOUT, addr promptY, sizeof promptY, addr bytesWritten, 0

    invoke ReadConsole, handleSTDIN, addr coordY, bufferSize, addr bytesRead, 0
    

    
;---------- Leitura da largura e altura -------------------------------------------------


    invoke WriteConsole, handleSTDOUT, addr promptLargura, sizeof promptLargura, addr bytesWritten, 0

    invoke ReadConsole, handleSTDIN, addr largura, bufferSize, addr bytesRead, 0

    
    invoke WriteConsole, handleSTDOUT, addr promptAltura, sizeof promptAltura, addr bytesWritten, 0

    invoke ReadConsole, handleSTDIN, addr altura, bufferSize, addr bytesRead, 0
    

    
;---------- Leitura do nome do arquivo que vai ser criado -------------------------------


    invoke WriteConsole, handleSTDOUT, addr promptOutputName, sizeof promptOutputName, addr bytesWritten, 0

    invoke ReadConsole, handleSTDIN, addr bufferOutputName, bufferSize, addr bytesRead, 0

    invoke WriteConsole, handleSTDOUT, addr bufferOutputName, [bytesRead], addr bytesWritten, 0


;---------- Tratamento dos valores de entrada do console ------------------


    mov esi, offset bufferInputNome 

proximo:

    mov al, [esi] 
    inc esi 
    cmp al, 13 
    jne proximo
    dec esi 
    xor al, al 
    mov [esi], al 


    inc contador
    cmp contador, 6
    je finalTratamento

    cmp contador, 5
    je nomeSaidaTra

    cmp contador, 4
    je coordXTra

    cmp contador, 3
    je coordYTra

    cmp contador, 2
    je larguraTra

    cmp contador, 1
    je alturaTra


nomeSaidaTra:
    
    mov esi, 0
    mov esi, offset bufferOutputName 
    jmp proximo

coordXTra:
    
    mov esi, 0
    mov esi, offset coordX 
    jmp proximo

coordYTra:
    
    mov esi, 0
    mov esi, offset coordY 
    jmp proximo

larguraTra:
    
    mov esi, 0
    mov esi, offset largura
    jmp proximo

alturaTra:
    
    mov esi, 0
    mov esi, offset altura
    jmp proximo

finalTratamento:

    invoke atodw, addr coordX
    mov coordX, eax


    invoke atodw, addr coordY
    mov coordY, eax

    invoke atodw, addr largura
    mov largura, eax

    invoke atodw, addr altura
    mov altura, eax



;--------- Abertura do arquivo e criaçao de um novo arquivo ---------------------------------------------------------------------------------------


    invoke CreateFile, addr bufferInputNome, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    mov inputFileHandle, eax

    invoke CreateFile, addr bufferOutputName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL
    
    mov outputFileHandle, eax

;--------- Passando os primeiros 18 Bytes do cabeçalho--------------------------------------------------------------------------------------


    invoke ReadFile, inputFileHandle , addr fileBuffer, 18, addr readCount, NULL 

    invoke WriteFile, outputFileHandle , addr fileBuffer, 18, addr writeCount, NULL
    

;--------- Obtendo a largura da imagem do arquivo de origem e passando para o arquivo de destino ------------------------------------------


    invoke ReadFile, inputFileHandle, addr larguraImagem, 4, addr readCount, NULL


    invoke WriteFile, outputFileHandle, addr larguraImagem, 4, addr writeCount, NULL


;---------- Passando o restante do cabeçalho --------------------------------------------------------------------------------------------------


    invoke ReadFile, inputFileHandle , addr fileBuffer, 32, addr readCount, NULL 

    invoke WriteFile, outputFileHandle , addr fileBuffer, 32, addr writeCount, NULL
    

;---------- loop de copia da imagem de origem para o novo arquivo de imagem --------------------------------------


    mov eax, larguraImagem
    mov ebx, 3
    mul ebx

    mov larguraImagem, eax

loopPixel:

    mov ebx, larguraImagem
    invoke ReadFile, inputFileHandle, addr fileBuffer, ebx, addr readCount, NULL
    invoke WriteFile, outputFileHandle, addr fileBuffer, ebx, addr writeCount, NULL

    mov eax, 0
    cmp readCount, eax 
    je fimLoop
    jmp loopPixel


fimLoop:

    invoke CloseHandle, inputFileHandle
    invoke CloseHandle, outputFileHandle

    
    invoke ExitProcess, 0
end start 