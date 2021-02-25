# Mishka's Image to Text converter

This is a small FreeBASIC application to convert images to text, using several different styles and also supporting ANSI color codes. It requires Free Image to load image files.

## Examples
Example (using --2tone - might not display correctly as it uses Unicode block drawing characters)
```
                                       ▗▟▟██     
                      ▄▖              ▗▟▛█▄█▟▖    
                     ▝██▄           ▗▟█▛▀█▝ ▞▌    
                      ▜██▖ ▗       ▄█▜▄▝▀   ▟▌    
                      ▜███▄▙▙▗▄▄▄▟██▜██     ▜▘    
                      ▗███████▜███▛ ▛▙▘    ▄█▌    
                ▄    ▗▟█▟▚▛▘▗▀▀▙█▜█▖▖    ▖▖▛▞ ▖   
                ▗▟███▌▀██▟▞ ▝ ▗ ▝▜██▙▖ ▗▟▟█▜▘██▌▞▌
             ▐▖█████▄▞█▄▚█▄ ▖▀▚▄  ▀█▐███ ▀ ▀█████▌
              ▜▀▀ █▝▜██▐███▙▛█▜▛▖▟  ▐▟██▟▙▖▟██████
               ▛ ▄▛  ▖ ▘▀ ▜█████████▞▟▟█▛▀████████
               ▘  ▝▗    ▐▌▄  ▀███████▜█▟▙▌████████
                    ▌ ▗        ▝▀▜█▛██████████████
                    ▀▖            ▐█▛▝▌▛▛▙████████
                      ▘▖            ▚▄▄█▛▘▝▛▜▀████
                        ▚   ▖  ▗▖    ▌▜▖ ▝▗▝▜▙██▙█
                         ▜▞▟▄ ▖▐█▙  ▞▀█ ▝ ▐▐▛▌▜▟▌▜
                        ▝▚▜█▞▐██▜▌    ▖  ▘▗▄▚▞▛█▟▝
                          ▜▜▘▐███         ▝▝▞▜▐▖ ▖
                          ▝█ ▟██▘     ▝ ▗▝  ▄▌▀▄ ▀
                          ▐█▙▜▛          ▄▐▞▙▄▘▘▖▄
                          █▀▜█▌▗           ▘▘▘▛▌▗▟
                       ▗▖▐██▛▙▜█▄      ▗▖   ▘▄▖▀▄ 
                        ▝██▐▀▚▘ ▜█▖      ▘▙▘ ▖▛▗▗▛
                                 ▜▜█ ▖ ▚     ▀ ▗ ▘
                                  ▀█▜▖▘▘▖▄▗ ▐  ▝▝▝
                                   ▜▀█▙▘ ▜▀▘▘     
                                    ▖▜█▙▞ ▌     
```

Example (using --ascii)
```                                   
                                                                     
                                                      
              ++++++++++                              
           ++++++##########                           
          ++++++############.                         
        --++++++############++                        
       ..-++++++++++++++#####++                       
       -..--------------++####+                       
       --.-------.....--+++##++.                      
       --.+--++++--.--+++####++.                      
       --.+++-.. .---.. .+###++-                      
       ..++     ....-..     #+-.                      
       ...        .+..       .-                       
       ...       ..+-        --                       
       ...       ---+.      .++                       
       .---    -.-  -+.-.  .+-+                       
       .-. .. . .     .   ..---                       
        ..     .      -.    --                        
            ...-.... .+-...  .                        
             --+-..--+++-                             
             ..--. .-....                             
              .---------                              
                                                                           
                                                                      
```

## Usage
```
Usage:
./imgconv <mode> <args> <image>

Arguments:
 -w            Output image width
 -h            Output image height

 --shaded	Use Unicode shading characters
 --2tone	Use 'high resoloution' halftone
 --block	Use the full block character and spaces
 --ascii	Use ascii characters

 --color	Output ANSII color codes (not available in all modes)
 --threshold    Specify the halftone threshold (0-255)
 --pallete      Specify the ASCII pallete to be used (only works in --ascii mode and only with ASCII characters)
```

---
FreeBASIC: [FreeBASIC.net](https://freebasic.net/)

