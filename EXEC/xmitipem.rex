        /* rexx ispf edit macro for use in the XMITIP application */
        Address ISREdit
        "Macro"
        "Caps Off"
        "Number Off"
        "Recovery Off"
        "Reset"
        Address ISPExec "Vget (Tenter enrich)"
        if pos(enrich,"enrich html") > 0 then do
           call do_line "Sample HTML Commands:"
           call do_line "<b> bold </b> unbold"
           call do_line "<i> italic </i> unitalic"
           call do_line "<center> center </center> uncenter"
           end
        if tenter <> "" then
           "TEnter .zl"
        exit

        Do_Line:
           parse arg newline
           if pos(enrich,"enrich html") > 0
              then
                 "LINE_Before .zfirst = msgline (newline)"
              else
                 "LINE_After .zfirst = msgline (newline)"
           return
