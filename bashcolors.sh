#!/bin/bash
# This is a library for bash, do not run it - it will be just included by other scripts
# From http://mywiki.wooledge.org/BashFAQ/037
#
# This are colors (and other special commands) for terminal requests.

# Variables for terminal requests.
[[ -t 2 ]] && { 
    bcolor_alt=$(      tput smcup  || tput ti      ) # Start alt display
    bcolor_ealt=$(     tput rmcup  || tput te      ) # End   alt display
    bcolor_hide=$(     tput civis  || tput vi      ) # Hide cursor
    bcolor_show=$(     tput cnorm  || tput ve      ) # Show cursor
    bcolor_save=$(     tput sc                     ) # Save cursor
    bcolor_load=$(     tput rc                     ) # Load cursor
    bcolor_bold=$(     tput bold   || tput md      ) # Start bold
    bcolor_stout=$(    tput smso   || tput so      ) # Start stand-out
    bcolor_estout=$(   tput rmso   || tput se      ) # End stand-out
    bcolor_under=$(    tput smul   || tput us      ) # Start underline
    bcolor_eunder=$(   tput rmul   || tput ue      ) # End   underline
    bcolor_reset=$(    tput sgr0   || tput me      ) # Reset cursor
    bcolor_blink=$(    tput blink  || tput mb      ) # Start blinking
    bcolor_italic=$(   tput sitm   || tput ZH      ) # Start italic
    bcolor_eitalic=$(  tput ritm   || tput ZR      ) # End   italic
[[ $TERM != *-m ]] && { 
    bcolor_red=$(      tput setaf 1|| tput AF 1    )
    bcolor_green=$(    tput setaf 2|| tput AF 2    )
    bcolor_yellow=$(   tput setaf 3|| tput AF 3    )
    bcolor_blue=$(     tput setaf 4|| tput AF 4    )
    bcolor_magenta=$(  tput setaf 5|| tput AF 5    )
    bcolor_cyan=$(     tput setaf 6|| tput AF 6    )

    bcolor_bgrred=$(      tput setab 1|| tput AB 1    )
    bcolor_bgrgreen=$(    tput setab 2|| tput AB 2    )
    bcolor_bgryellow=$(   tput setab 3|| tput AB 3    )
    bcolor_bgrblue=$(     tput setab 4|| tput AB 4    )
    bcolor_bgrmagenta=$(  tput setab 5|| tput AB 5    )
    bcolor_bgrcyan=$(     tput setab 6|| tput AB 6    )
}
    bcolor_black=$(    tput setaf 0 || tput AF 0    )
    bcolor_bgrblack=$(    tput setab 0 || tput AB 0    )
    bcolor_white=$(    tput setaf 7 || tput AF 7    )
    bcolor_bgrwhite=$(    tput setab 7 || tput AB 7    )
    
		bcolor_default=$(  tput op                     )
		bcolor_zero="$bcolor_reset"
	
    bcolor_eed=$(      tput ed     || tput cd      )   # Erase to end of display
    bcolor_eel=$(      tput el     || tput ce      )   # Erase to end of line
    bcolor_ebl=$(      tput el1    || tput cb      )   # Erase to beginning of line
    bcolor_ewl=$eel$ebl                                # Erase whole line
    bcolor_draw=$(     tput -S <<< '   enacs
                                smacs
                                acsc
                                rmacs' || { \
                tput eA; tput as;
                tput ac; tput ae;         } )   # Drawing characters
    bcolor_back=$'\b'
} 2>/dev/null ||:

function print_ok_header() {
	echo -e "\n$bcolor_bgrgreen   $bcolor_bgrblack$bcolor_green $1 $bcolor_bgrgreen$bcolor_eel$bcolor_zero\n"
}

