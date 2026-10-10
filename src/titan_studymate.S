# Titan StudyMate — x86-64 Linux / GNU assembler implementation.
# The web server, request handling, page rendering, prompt construction, and
# response parsing are all written in assembly. curl is used as the TLS client.

.intel_syntax noprefix

.macro APPEND source
    lea rdi, [rip + page_buf]
    lea rsi, [rip + \source]
    call strcat@PLT
.endm

.section .rodata
.align 8

port_env:               .asciz "PORT"
api_key_env:            .asciz "GOOGLE_API_KEY"
model_env:              .asciz "GEMINI_MODEL"
default_model:          .asciz "gemini-2.5-flash"
url_format:             .asciz "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent"
api_header_format:      .asciz "header = \"Content-Type: application/json\"\nheader = \"x-goog-api-key: %s\"\n"
startup_format:         .asciz "Titan StudyMate (x86-64 assembly) listening on 0.0.0.0:%d\n"
bind_error:             .asciz "Titan StudyMate: could not bind the requested port"
listen_error:           .asciz "Titan StudyMate: could not start listening"

http_separator:         .asciz "\r\n\r\n"
content_length_header:  .asciz "Content-Length:"
post_method:            .asciz "POST "
field_grade:            .asciz "grade="
field_subject:          .asciz "subject="
field_question:         .asciz "question="
default_grade:          .asciz "Class 1"
default_subject:        .asciz "Maths"
empty_string:           .asciz ""

prompt_format:          .asciz "You are a friendly, encouraging expert teacher for a %s student. The subject is %s. Explain the student's doubt clearly, simply, and step by step in Hinglish (Hindi + English mix), using a real-life example. Keep the explanation under 300 words.\n\nStudent's doubt: %s"
json_prefix:            .asciz "{\"contents\":[{\"parts\":[{\"text\":\""
json_suffix:            .asciz "\"}]}],\"generationConfig\":{\"temperature\":0.4,\"maxOutputTokens\":512}}"
hex_digits:             .asciz "0123456789ABCDEF"
json_text_key:          .asciz "\"text\""
json_message_key:       .asciz "\"message\""

curl_command:           .asciz "curl"
curl_silent:            .asciz "--silent"
curl_show_error:        .asciz "--show-error"
curl_connect_timeout:   .asciz "--connect-timeout"
curl_connect_seconds:   .asciz "10"
curl_max_time:          .asciz "--max-time"
curl_max_seconds:       .asciz "45"
curl_config_option:     .asciz "--config"
curl_config_fd:         .asciz "/dev/fd/3"
curl_data:              .asciz "--data-binary"
curl_stdin:             .asciz "@-"

html_start:
.asciz "<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<meta name=\"theme-color\" content=\"#f6f7fb\">\n<title>Titan StudyMate — AI Doubt Solver</title>\n<style>\n"
html_styles:
.asciz ":root{color-scheme:light;--ink:#18213a;--muted:#66708a;--line:#e7eaf1;--paper:#fff;--canvas:#f6f7fb;--violet:#635bdb;--violet-dark:#5149c8;--mint:#e9f8f3;--gold:#f7c66b}*{box-sizing:border-box}body{margin:0;background:radial-gradient(ellipse at 12% 0%,#eeeaff 0,transparent 34%),var(--canvas);color:var(--ink);font:16px/1.55 Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,\"Segoe UI\",sans-serif}.shell{width:min(100% - 36px,1080px);margin:0 auto}.topbar{display:flex;align-items:center;justify-content:space-between;padding:23px 0}.brand{display:flex;align-items:center;gap:12px;color:inherit;text-decoration:none}.brand-mark{display:grid;place-items:center;width:45px;height:45px;border-radius:15px;background:#fff;box-shadow:0 5px 18px #342c7918;font-size:23px}.brand-name{display:block;font-size:15px;font-weight:800;letter-spacing:.035em}.brand-note{display:block;color:var(--muted);font-size:12px}.top-pill{border:1px solid #e7e2ff;border-radius:999px;background:#fff;color:#5d54c9;padding:7px 12px;font-size:12px;font-weight:700}.hero{padding:40px 0 25px;max-width:760px}.eyebrow{color:var(--violet);font-size:11px;font-weight:800;letter-spacing:.15em;text-transform:uppercase}.hero h1{margin:9px 0 12px;font-size:clamp(34px,5vw,56px);line-height:1.08;letter-spacing:-.045em}.hero h1 span{color:var(--violet)}.hero p{max-width:610px;margin:0;color:var(--muted);font-size:17px}.workspace{display:grid;grid-template-columns:minmax(280px,.88fr) minmax(0,1.12fr);align-items:start;gap:20px;padding:12px 0 45px}.card{overflow:hidden;border:1px solid #e9ebf2;border-radius:22px;background:var(--paper);box-shadow:0 12px 38px #2830520b}.settings-card{padding:25px}.card-heading{margin-bottom:20px}.card-heading h2{margin:5px 0 0;font-size:19px;letter-spacing:-.02em}.fields{display:grid;grid-template-columns:1fr 1fr;gap:13px}.field label{display:block;margin:0 0 7px;color:#49536d;font-size:12px;font-weight:750}.field select,.field textarea{width:100%;border:1px solid #e1e5ee;border-radius:12px;background:#fff;color:var(--ink);font:inherit;outline:none;transition:border-color .15s,box-shadow .15s}.field select{height:45px;padding:0 12px}.field textarea{min-height:150px;resize:vertical;padding:12px 13px;line-height:1.55}.field select:focus,.field textarea:focus{border-color:#8e88eb;box-shadow:0 0 0 3px #635bdb19}.question-field{margin-top:17px}.field textarea::placeholder{color:#a0a7b7}.submit-button{display:flex;align-items:center;justify-content:center;gap:9px;width:100%;min-height:49px;margin-top:16px;border:0;border-radius:13px;background:var(--violet);color:#fff;font:inherit;font-weight:750;cursor:pointer;box-shadow:0 7px 15px #635bdb32;transition:background .15s,transform .15s}.submit-button:hover{background:var(--violet-dark);transform:translateY(-1px)}.form-hint{margin:11px 0 0;color:#8991a4;text-align:center;font-size:11px}.answer-column{min-width:0}.answer-label{display:flex;align-items:center;gap:10px;margin:6px 0 13px}.answer-label .sparkle{display:grid;place-items:center;width:32px;height:32px;border-radius:11px;background:#fff5dc;color:#ba841d;font-size:17px}.answer-label strong{font-size:14px}.answer-card{padding:25px;border:1px solid #e9ebf2;border-radius:22px;background:#fff;box-shadow:0 12px 38px #2830520b}.answer-card-head{display:flex;align-items:center;gap:12px;padding-bottom:17px;border-bottom:1px solid #eff0f5}.answer-badge{display:grid;place-items:center;width:39px;height:39px;border-radius:13px;background:var(--mint);font-size:20px}.answer-card-head h2{margin:1px 0 0;font-size:18px}.answer-copy{padding-top:17px;color:#3e4861;white-space:pre-wrap;overflow-wrap:anywhere}.empty-state{min-height:290px;display:flex;flex-direction:column;align-items:center;justify-content:center;padding:38px 30px;border:1px dashed #d8dced;border-radius:22px;background:#ffffffa8;text-align:center}.empty-icon{display:grid;place-items:center;width:54px;height:54px;border-radius:18px;background:#fff4d7;color:#ac7c20;font-size:25px}.empty-state h2{margin:16px 0 5px;font-size:19px}.empty-state p{max-width:330px;margin:0;color:var(--muted);font-size:14px}.notice{margin:0 0 14px;padding:15px 17px;border:1px solid #f1d8ad;border-radius:14px;background:#fffaf0;color:#704b12;font-size:14px}.notice strong{display:block;margin-bottom:3px}.notice p{margin:0;overflow-wrap:anywhere}.footer{display:flex;justify-content:space-between;gap:16px;padding:18px 0 28px;border-top:1px solid var(--line);color:#8991a4;font-size:12px}.footer strong{color:#626b82}.footer a{color:#626b82;text-decoration:none}@media(max-width:740px){.shell{width:min(100% - 24px,600px)}.topbar{padding:17px 0}.top-pill{font-size:10px;padding:6px 9px}.hero{padding:29px 0 16px}.hero p{font-size:15px}.workspace{grid-template-columns:1fr;gap:18px;padding-top:7px}.settings-card,.answer-card{padding:20px}.answer-label{margin-top:1px}.footer{flex-direction:column;gap:4px}}@media(max-width:420px){.fields{grid-template-columns:1fr}.top-pill{display:none}.hero h1{font-size:36px}}\n</style>\n</head>\n<body>\n<div class=\"shell\">\n<header class=\"topbar\"><a class=\"brand\" href=\"/\"><span class=\"brand-mark\">&#127891;</span><span><span class=\"brand-name\">TITAN STUDYMATE</span><span class=\"brand-note\">A little help for big ideas</span></span></a><span class=\"top-pill\">MADE FOR CLASS 1–12</span></header>\n<main>\n<section class=\"hero\"><span class=\"eyebrow\">Your friendly AI study buddy</span><h1>Learn it. <span>Step by step.</span></h1><p>Bring any school doubt. Get a clear, encouraging explanation in easy Hinglish, made for your class and subject.</p></section>\n<div class=\"workspace\">\n<section class=\"card settings-card\"><div class=\"card-heading\"><span class=\"eyebrow\">First, tell me a little</span><h2>What are you studying?</h2></div>\n<form method=\"post\" action=\"/\"><div class=\"fields\"><div class=\"field\"><label for=\"grade\">Your class</label><select id=\"grade\" name=\"grade\">"
html_grade_to_subject:
.asciz "</select></div><div class=\"field\"><label for=\"subject\">Subject</label><select id=\"subject\" name=\"subject\">"
html_subject_to_question:
.asciz "</select></div></div><div class=\"field question-field\"><label for=\"question\">What's on your mind?</label><textarea id=\"question\" name=\"question\" maxlength=\"2000\" placeholder=\"For example: Newton's third law kya hai? Or help me solve 2x + 5 = 15.\">"
html_question_to_button:
.asciz "</textarea></div><button class=\"submit-button\" type=\"submit\">Solve my doubt <span aria-hidden=\"true\">&#8594;</span></button><p class=\"form-hint\">No question is too small. Ask away!</p></form></section>\n<section class=\"answer-column\"><div class=\"answer-label\"><span class=\"sparkle\">&#10024;</span><strong>Your explanation</strong></div>"
html_page_end:
.asciz "</section></div></main><footer class=\"footer\"><span>&copy; 2026 <strong>Titan StudyMate</strong> &middot; Curiosity looks good on you.</span><span>Powered by Gemini AI</span></footer></div></body></html>\n"

empty_result_html:
.asciz "<section class=\"empty-state\"><span class=\"empty-icon\">&#10022;</span><h2>Your explanation will show up here</h2><p>Choose your class and subject, then ask your question. We'll work through it together.</p></section>"
answer_result_format:
.asciz "<article class=\"answer-card\"><div class=\"answer-card-head\"><span class=\"answer-badge\">&#128161;</span><div><span class=\"eyebrow\">A little clarity, coming up</span><h2>Here's the idea</h2></div></div><div class=\"answer-copy\">%s</div></article>"
error_result_format:
.asciz "<section class=\"notice\"><strong>We couldn't get an answer just yet.</strong><p>%s</p></section><section class=\"empty-state\"><span class=\"empty-icon\">&#128172;</span><h2>Your doubt is still here</h2><p>Fix the note above and try again. Your question will stay in the box.</p></section>"
missing_key_error:
.asciz "The Gemini API key is not configured. Set GOOGLE_API_KEY in the environment, then restart Titan StudyMate."
blank_question_error:
.asciz "Please type a question before asking for an explanation."
request_failed_error:
.asciz "Gemini returned no readable answer. Check your network connection, API key, and GEMINI_MODEL setting, then try again."
curl_start_error:
.asciz "Could not start curl. Install curl and make sure it is available on PATH."

class_format:            .asciz "Class %d"
grade_option_format:     .asciz "<option value=\"Class %d\"%s>Class %d</option>"
selected_attr:           .asciz " selected"
no_attr:                 .asciz ""
subject_option_format:   .asciz "<option value=\"%s\"%s>%s</option>"
subject_maths:           .asciz "Maths"
subject_science:         .asciz "Science"
subject_physics:         .asciz "Physics"
subject_chemistry:       .asciz "Chemistry"
subject_biology:         .asciz "Biology"
subject_general:         .asciz "General"

http_response_format:
.asciz "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %zu\r\nConnection: close\r\nCache-Control: no-store\r\nX-Content-Type-Options: nosniff\r\nX-Frame-Options: DENY\r\nContent-Security-Policy: default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'\r\n\r\n"

.section .data
.align 8
subject_items:
    .quad subject_maths
    .quad subject_science
    .quad subject_physics
    .quad subject_chemistry
    .quad subject_biology
    .quad subject_general

.section .bss
.align 16
server_fd:              .zero 4
server_addr:            .zero 16
reuse_addr:             .zero 4
listen_port:            .zero 4
api_key_ptr:            .zero 8
model_ptr:              .zero 8

api_url_buf:            .zero 1024
api_header_buf:         .zero 8192
request_buf:            .zero 32768
request_header_len:     .zero 8
request_body_len:       .zero 8
grade_buf:              .zero 64
subject_buf:            .zero 64
question_buf:           .zero 8192
question_html:          .zero 49152
answer_raw:             .zero 65536
answer_html:            .zero 131072
error_buf:              .zero 4096
error_html:             .zero 24576
prompt_buf:             .zero 16384
json_body:              .zero 131072
json_body_len:          .zero 8
gemini_response:        .zero 65536
curl_discard:           .zero 4096
page_buf:               .zero 262144
page_length:            .zero 8
http_header_buf:        .zero 1024
grade_options_buf:      .zero 2048
subject_options_buf:    .zero 1024
result_html_buf:        .zero 160000
pipe_in:                .zero 8
pipe_out:               .zero 8
pipe_config:            .zero 8
child_status:           .zero 4
curl_argv:              .zero 120

.section .text
.globl main
.type main, @function
.extern socket
.extern setsockopt
.extern bind
.extern listen
.extern accept
.extern recv
.extern send
.extern close
.extern memset
.extern memcpy
.extern strcpy
.extern strcat
.extern strlen
.extern strcmp
.extern strncmp
.extern strstr
.extern strcasestr
.extern strchr
.extern atoi
.extern getenv
.extern snprintf
.extern printf
.extern fflush
.extern perror
.extern signal
.extern pipe
.extern fork
.extern dup2
.extern execvp
.extern _exit
.extern read
.extern write
.extern waitpid

main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    lea rdi, [rip + port_env]
    call getenv@PLT
    test rax, rax
    jz .Lport_default
    mov rdi, rax
    call atoi@PLT
    cmp eax, 1
    jl .Lport_default
    cmp eax, 65535
    jg .Lport_default
    mov dword ptr [rip + listen_port], eax
    jmp .Lport_ready
.Lport_default:
    mov dword ptr [rip + listen_port], 8501
.Lport_ready:

    lea rdi, [rip + api_key_env]
    call getenv@PLT
    mov qword ptr [rip + api_key_ptr], rax

    lea rdi, [rip + model_env]
    call getenv@PLT
    test rax, rax
    jz .Ldefault_model
    cmp byte ptr [rax], 0
    je .Ldefault_model
    mov qword ptr [rip + model_ptr], rax
    jmp .Lmodel_ready
.Ldefault_model:
    lea rax, [rip + default_model]
    mov qword ptr [rip + model_ptr], rax
.Lmodel_ready:

    lea rdi, [rip + api_url_buf]
    mov esi, 1024
    lea rdx, [rip + url_format]
    mov rcx, qword ptr [rip + model_ptr]
    xor eax, eax
    call snprintf@PLT

    mov rax, qword ptr [rip + api_key_ptr]
    test rax, rax
    jz .Lno_api_header
    lea rdi, [rip + api_header_buf]
    mov esi, 8192
    lea rdx, [rip + api_header_format]
    mov rcx, rax
    xor eax, eax
    call snprintf@PLT
.Lno_api_header:

    mov edi, 13
    mov esi, 1
    call signal@PLT

    mov edi, 2
    mov esi, 1
    xor edx, edx
    call socket@PLT
    test eax, eax
    js .Lsocket_error
    mov dword ptr [rip + server_fd], eax

    mov dword ptr [rip + reuse_addr], 1
    mov edi, dword ptr [rip + server_fd]
    mov esi, 1
    mov edx, 2
    lea rcx, [rip + reuse_addr]
    mov r8d, 4
    call setsockopt@PLT

    mov word ptr [rip + server_addr], 2
    mov eax, dword ptr [rip + listen_port]
    xchg al, ah
    mov word ptr [rip + server_addr + 2], ax
    mov dword ptr [rip + server_addr + 4], 0
    mov qword ptr [rip + server_addr + 8], 0

    mov edi, dword ptr [rip + server_fd]
    lea rsi, [rip + server_addr]
    mov edx, 16
    call bind@PLT
    test eax, eax
    js .Lbind_error

    mov edi, dword ptr [rip + server_fd]
    mov esi, 32
    call listen@PLT
    test eax, eax
    js .Llisten_error

    lea rdi, [rip + startup_format]
    mov esi, dword ptr [rip + listen_port]
    xor eax, eax
    call printf@PLT
    xor edi, edi
    call fflush@PLT

.Laccept_loop:
    mov edi, dword ptr [rip + server_fd]
    xor esi, esi
    xor edx, edx
    call accept@PLT
    test eax, eax
    js .Laccept_loop
    mov dword ptr [rbp - 4], eax
    mov edi, eax
    call handle_client
    mov edi, dword ptr [rbp - 4]
    call close@PLT
    jmp .Laccept_loop

.Lsocket_error:
    lea rdi, [rip + bind_error]
    call perror@PLT
    mov eax, 1
    leave
    ret
.Lbind_error:
    lea rdi, [rip + bind_error]
    call perror@PLT
    mov edi, dword ptr [rip + server_fd]
    call close@PLT
    mov eax, 1
    leave
    ret
.Llisten_error:
    lea rdi, [rip + listen_error]
    call perror@PLT
    mov edi, dword ptr [rip + server_fd]
    call close@PLT
    mov eax, 1
    leave
    ret
.size main, .-main

.type handle_client, @function
handle_client:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    mov r12d, edi

    lea rdi, [rip + request_buf]
    xor esi, esi
    mov edx, 32768
    call memset@PLT
    lea rdi, [rip + answer_raw]
    xor esi, esi
    mov edx, 65536
    call memset@PLT
    lea rdi, [rip + error_buf]
    xor esi, esi
    mov edx, 4096
    call memset@PLT
    lea rdi, [rip + grade_buf]
    lea rsi, [rip + default_grade]
    call strcpy@PLT
    lea rdi, [rip + subject_buf]
    lea rsi, [rip + default_subject]
    call strcpy@PLT
    lea rdi, [rip + question_buf]
    xor esi, esi
    mov edx, 8192
    call memset@PLT
    mov qword ptr [rip + request_header_len], 0
    mov qword ptr [rip + request_body_len], 0

    xor r13d, r13d
.Lread_request:
    cmp r13d, 32767
    jae .Lrequest_too_large
    mov edi, r12d
    lea rsi, [rip + request_buf]
    add rsi, r13
    mov edx, 32767
    sub rdx, r13
    xor ecx, ecx
    call recv@PLT
    test rax, rax
    jle .Lclient_done
    add r13, rax
    lea rax, [rip + request_buf]
    mov byte ptr [rax + r13], 0

    lea rdi, [rip + request_buf]
    lea rsi, [rip + http_separator]
    call strstr@PLT
    test rax, rax
    jz .Lread_request
    mov r14, rax

    lea rdi, [rip + request_buf]
    lea rsi, [rip + content_length_header]
    call strcasestr@PLT
    xor r15d, r15d
    test rax, rax
    jz .Lrequest_length_ready
    add rax, 15
    mov rdi, rax
    call atoi@PLT
    test eax, eax
    js .Lrequest_too_large
    mov r15d, eax
    cmp r15d, 30000
    ja .Lrequest_too_large
.Lrequest_length_ready:
    lea rax, [r14 + 4]
    lea rdx, [rip + request_buf]
    sub rax, rdx
    mov qword ptr [rip + request_header_len], rax
    mov qword ptr [rip + request_body_len], r15
    add rax, r15
    cmp r13, rax
    jb .Lread_request
    jmp .Lrequest_ready

.Lrequest_too_large:
    jmp .Lclient_done

.Lrequest_ready:
    lea rdi, [rip + request_buf]
    lea rsi, [rip + post_method]
    mov edx, 5
    call strncmp@PLT
    test eax, eax
    jne .Lrender_page

    lea rdi, [rip + request_buf]
    mov rax, qword ptr [rip + request_header_len]
    add rdi, rax
    lea rsi, [rip + field_grade]
    call strstr@PLT
    test rax, rax
    jz .Lparse_subject
    add rax, 6
    mov rdi, rax
    lea rsi, [rip + grade_buf]
    mov edx, 64
    call url_decode

.Lparse_subject:
    lea rdi, [rip + request_buf]
    mov rax, qword ptr [rip + request_header_len]
    add rdi, rax
    lea rsi, [rip + field_subject]
    call strstr@PLT
    test rax, rax
    jz .Lparse_question
    add rax, 8
    mov rdi, rax
    lea rsi, [rip + subject_buf]
    mov edx, 64
    call url_decode

.Lparse_question:
    lea rdi, [rip + request_buf]
    mov rax, qword ptr [rip + request_header_len]
    add rdi, rax
    lea rsi, [rip + field_question]
    call strstr@PLT
    test rax, rax
    jz .Lquestion_ready
    add rax, 9
    mov rdi, rax
    lea rsi, [rip + question_buf]
    mov edx, 8192
    call url_decode

.Lquestion_ready:
    lea rdi, [rip + question_buf]
    call is_blank
    test eax, eax
    jnz .Lblank_question
    mov rax, qword ptr [rip + api_key_ptr]
    test rax, rax
    jz .Lmissing_key
    cmp byte ptr [rax], 0
    je .Lmissing_key

    call build_prompt_json
    call call_gemini
    test eax, eax
    jz .Lparse_gemini
    lea rdi, [rip + error_buf]
    lea rsi, [rip + curl_start_error]
    call strcpy@PLT
    jmp .Lrender_page
.Lparse_gemini:
    call parse_gemini_response
    jmp .Lrender_page

.Lblank_question:
    lea rdi, [rip + error_buf]
    lea rsi, [rip + blank_question_error]
    call strcpy@PLT
    jmp .Lrender_page
.Lmissing_key:
    lea rdi, [rip + error_buf]
    lea rsi, [rip + missing_key_error]
    call strcpy@PLT

.Lrender_page:
    call build_page
    lea rdi, [rip + page_buf]
    call strlen@PLT
    mov qword ptr [rip + page_length], rax

    lea rdi, [rip + http_header_buf]
    mov esi, 1024
    lea rdx, [rip + http_response_format]
    mov rcx, qword ptr [rip + page_length]
    xor eax, eax
    call snprintf@PLT

    mov edi, r12d
    lea rsi, [rip + http_header_buf]
    lea rdi, [rip + http_header_buf]
    call strlen@PLT
    mov rdx, rax
    mov edi, r12d
    lea rsi, [rip + http_header_buf]
    call write_full

    mov edi, r12d
    lea rsi, [rip + page_buf]
    mov rdx, qword ptr [rip + page_length]
    call write_full

.Lclient_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
.size handle_client, .-handle_client

.type url_decode, @function
url_decode:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    xor r15d, r15d
    test r14, r14
    jz .Lurl_return
.Lurl_loop:
    lea rax, [r15 + 1]
    cmp rax, r14
    jae .Lurl_finish
    movzx eax, byte ptr [r12]
    test al, al
    jz .Lurl_finish
    cmp al, '&'
    je .Lurl_finish
    cmp al, '+'
    je .Lurl_plus
    cmp al, '%'
    jne .Lurl_copy
    cmp byte ptr [r12 + 1], 0
    je .Lurl_copy
    cmp byte ptr [r12 + 2], 0
    je .Lurl_copy
    movzx edi, byte ptr [r12 + 1]
    call hex_digit
    test eax, eax
    js .Lurl_copy
    mov r10d, eax
    movzx edi, byte ptr [r12 + 2]
    call hex_digit
    test eax, eax
    js .Lurl_copy
    shl r10d, 4
    or r10d, eax
    mov byte ptr [r13 + r15], r10b
    add r12, 3
    inc r15
    jmp .Lurl_loop
.Lurl_plus:
    mov byte ptr [r13 + r15], ' '
    inc r12
    inc r15
    jmp .Lurl_loop
.Lurl_copy:
    mov al, byte ptr [r12]
    mov byte ptr [r13 + r15], al
    inc r12
    inc r15
    jmp .Lurl_loop
.Lurl_finish:
    mov byte ptr [r13 + r15], 0
.Lurl_return:
    mov rax, r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
.size url_decode, .-url_decode

.type hex_digit, @function
hex_digit:
    mov eax, edi
    cmp eax, '0'
    jb .Lhex_upper
    cmp eax, '9'
    jbe .Lhex_numeric
.Lhex_upper:
    cmp eax, 'A'
    jb .Lhex_lower
    cmp eax, 'F'
    jbe .Lhex_upper_value
.Lhex_lower:
    cmp eax, 'a'
    jb .Lhex_bad
    cmp eax, 'f'
    ja .Lhex_bad
    sub eax, 'a' - 10
    ret
.Lhex_upper_value:
    sub eax, 'A' - 10
    ret
.Lhex_numeric:
    sub eax, '0'
    ret
.Lhex_bad:
    mov eax, -1
    ret
.size hex_digit, .-hex_digit

.type is_blank, @function
is_blank:
    mov rax, rdi
.Lblank_loop:
    movzx ecx, byte ptr [rax]
    test cl, cl
    jz .Lblank_yes
    cmp cl, ' '
    je .Lblank_next
    cmp cl, 9
    je .Lblank_next
    cmp cl, 10
    je .Lblank_next
    cmp cl, 13
    je .Lblank_next
    xor eax, eax
    ret
.Lblank_next:
    inc rax
    jmp .Lblank_loop
.Lblank_yes:
    mov eax, 1
    ret
.size is_blank, .-is_blank

.type build_prompt_json, @function
build_prompt_json:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8

    lea rdi, [rip + prompt_buf]
    mov esi, 16384
    lea rdx, [rip + prompt_format]
    lea rcx, [rip + grade_buf]
    lea r8, [rip + subject_buf]
    lea r9, [rip + question_buf]
    xor eax, eax
    call snprintf@PLT

    lea rdi, [rip + json_body]
    lea rsi, [rip + json_prefix]
    call strcpy@PLT
    lea rdi, [rip + json_body]
    call strlen@PLT
    lea r12, [rip + json_body]
    add r12, rax
    lea r13, [rip + prompt_buf]
.Ljson_escape_loop:
    movzx eax, byte ptr [r13]
    test al, al
    jz .Ljson_escape_done
    cmp al, '"'
    je .Ljson_escape_quote
    cmp al, '\\'
    je .Ljson_escape_slash
    cmp al, 10
    je .Ljson_escape_newline
    cmp al, 13
    je .Ljson_escape_return
    cmp al, 9
    je .Ljson_escape_tab
    cmp al, 8
    je .Ljson_escape_backspace
    cmp al, 12
    je .Ljson_escape_formfeed
    cmp al, 32
    jb .Ljson_escape_control
    mov byte ptr [r12], al
    inc r12
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_quote:
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], '"'
    add r12, 2
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_slash:
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], '\\'
    add r12, 2
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_newline:
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], 'n'
    add r12, 2
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_return:
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], 'r'
    add r12, 2
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_tab:
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], 't'
    add r12, 2
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_backspace:
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], 'b'
    add r12, 2
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_formfeed:
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], 'f'
    add r12, 2
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_control:
    movzx eax, byte ptr [r13]
    mov byte ptr [r12], '\\'
    mov byte ptr [r12 + 1], 'u'
    mov byte ptr [r12 + 2], '0'
    mov byte ptr [r12 + 3], '0'
    mov edx, eax
    shr eax, 4
    and edx, 15
    lea r10, [rip + hex_digits]
    mov al, byte ptr [r10 + rax]
    mov byte ptr [r12 + 4], al
    mov al, byte ptr [r10 + rdx]
    mov byte ptr [r12 + 5], al
    add r12, 6
    inc r13
    jmp .Ljson_escape_loop
.Ljson_escape_done:
    mov byte ptr [r12], 0
    mov rdi, r12
    lea rsi, [rip + json_suffix]
    call strcpy@PLT
    lea rdi, [rip + json_body]
    call strlen@PLT
    mov qword ptr [rip + json_body_len], rax

    add rsp, 8
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
.size build_prompt_json, .-build_prompt_json

.type call_gemini, @function
call_gemini:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15

    lea rdi, [rip + gemini_response]
    xor esi, esi
    mov edx, 65536
    call memset@PLT
    lea rdi, [rip + pipe_in]
    call pipe@PLT
    test eax, eax
    js .Lcurl_setup_fail
    lea rdi, [rip + pipe_out]
    call pipe@PLT
    test eax, eax
    js .Lcurl_pipe_out_fail
    lea rdi, [rip + pipe_config]
    call pipe@PLT
    test eax, eax
    js .Lcurl_pipe_config_fail

    lea rax, [rip + curl_command]
    mov qword ptr [rip + curl_argv], rax
    lea rax, [rip + curl_silent]
    mov qword ptr [rip + curl_argv + 8], rax
    lea rax, [rip + curl_show_error]
    mov qword ptr [rip + curl_argv + 16], rax
    lea rax, [rip + curl_connect_timeout]
    mov qword ptr [rip + curl_argv + 24], rax
    lea rax, [rip + curl_connect_seconds]
    mov qword ptr [rip + curl_argv + 32], rax
    lea rax, [rip + curl_max_time]
    mov qword ptr [rip + curl_argv + 40], rax
    lea rax, [rip + curl_max_seconds]
    mov qword ptr [rip + curl_argv + 48], rax
    lea rax, [rip + curl_config_option]
    mov qword ptr [rip + curl_argv + 56], rax
    lea rax, [rip + curl_config_fd]
    mov qword ptr [rip + curl_argv + 64], rax
    lea rax, [rip + curl_data]
    mov qword ptr [rip + curl_argv + 72], rax
    lea rax, [rip + curl_stdin]
    mov qword ptr [rip + curl_argv + 80], rax
    lea rax, [rip + api_url_buf]
    mov qword ptr [rip + curl_argv + 88], rax
    mov qword ptr [rip + curl_argv + 96], 0

    call fork@PLT
    test rax, rax
    js .Lcurl_fork_fail
    jz .Lcurl_child
    mov r12, rax

    mov edi, dword ptr [rip + pipe_in]
    call close@PLT
    mov edi, dword ptr [rip + pipe_out + 4]
    call close@PLT
    mov edi, dword ptr [rip + pipe_config]
    call close@PLT

    lea rdi, [rip + api_header_buf]
    call strlen@PLT
    mov r14, rax
    xor r15d, r15d
.Lcurl_write_config:
    cmp r15, r14
    jae .Lcurl_close_config
    mov edi, dword ptr [rip + pipe_config + 4]
    lea rsi, [rip + api_header_buf]
    add rsi, r15
    mov rdx, r14
    sub rdx, r15
    call write@PLT
    test rax, rax
    jle .Lcurl_close_config
    add r15, rax
    jmp .Lcurl_write_config
.Lcurl_close_config:
    mov edi, dword ptr [rip + pipe_config + 4]
    call close@PLT

    mov r13d, dword ptr [rip + pipe_in + 4]
    mov r14, qword ptr [rip + json_body_len]
    xor r15d, r15d
.Lcurl_write_body:
    cmp r15, r14
    jae .Lcurl_close_stdin
    mov edi, r13d
    lea rsi, [rip + json_body]
    add rsi, r15
    mov rdx, r14
    sub rdx, r15
    call write@PLT
    test rax, rax
    jle .Lcurl_close_stdin
    add r15, rax
    jmp .Lcurl_write_body
.Lcurl_close_stdin:
    mov edi, r13d
    call close@PLT
    mov edi, dword ptr [rip + pipe_out + 4]
    call close@PLT
    mov r13d, dword ptr [rip + pipe_out]
    xor r14d, r14d
.Lcurl_read_response:
    cmp r14d, 65535
    jae .Lcurl_read_discard
    mov edi, r13d
    lea rsi, [rip + gemini_response]
    add rsi, r14
    mov edx, 65535
    sub edx, r14d
    call read@PLT
    test rax, rax
    jle .Lcurl_response_done
    add r14, rax
    lea rax, [rip + gemini_response]
    mov byte ptr [rax + r14], 0
    jmp .Lcurl_read_response
.Lcurl_read_discard:
    mov edi, r13d
    lea rsi, [rip + curl_discard]
    mov edx, 4096
    call read@PLT
    test rax, rax
    jg .Lcurl_read_discard
.Lcurl_response_done:
    lea rax, [rip + gemini_response]
    mov byte ptr [rax + r14], 0
    mov edi, r13d
    call close@PLT
    mov edi, r12d
    lea rsi, [rip + child_status]
    xor edx, edx
    call waitpid@PLT
    xor eax, eax
    jmp .Lcurl_return

.Lcurl_child:
    mov edi, dword ptr [rip + pipe_in + 4]
    call close@PLT
    mov edi, dword ptr [rip + pipe_out]
    call close@PLT
    mov edi, dword ptr [rip + pipe_config + 4]
    call close@PLT
    mov edi, dword ptr [rip + pipe_in]
    xor esi, esi
    call dup2@PLT
    mov edi, dword ptr [rip + pipe_out + 4]
    mov esi, 1
    call dup2@PLT
    mov edi, dword ptr [rip + pipe_out + 4]
    mov esi, 2
    call dup2@PLT
    mov edi, dword ptr [rip + pipe_config]
    mov esi, 3
    call dup2@PLT
    mov edi, dword ptr [rip + pipe_in]
    call close@PLT
    mov edi, dword ptr [rip + pipe_out + 4]
    call close@PLT
    mov edi, dword ptr [rip + pipe_config]
    call close@PLT
    lea rdi, [rip + curl_command]
    lea rsi, [rip + curl_argv]
    call execvp@PLT
    mov edi, 127
    call _exit@PLT

.Lcurl_pipe_out_fail:
    mov edi, dword ptr [rip + pipe_in]
    call close@PLT
    mov edi, dword ptr [rip + pipe_in + 4]
    call close@PLT
    jmp .Lcurl_setup_fail
.Lcurl_pipe_config_fail:
    mov edi, dword ptr [rip + pipe_in]
    call close@PLT
    mov edi, dword ptr [rip + pipe_in + 4]
    call close@PLT
    mov edi, dword ptr [rip + pipe_out]
    call close@PLT
    mov edi, dword ptr [rip + pipe_out + 4]
    call close@PLT
    jmp .Lcurl_setup_fail
.Lcurl_fork_fail:
    mov edi, dword ptr [rip + pipe_in]
    call close@PLT
    mov edi, dword ptr [rip + pipe_in + 4]
    call close@PLT
    mov edi, dword ptr [rip + pipe_out]
    call close@PLT
    mov edi, dword ptr [rip + pipe_out + 4]
    call close@PLT
    mov edi, dword ptr [rip + pipe_config]
    call close@PLT
    mov edi, dword ptr [rip + pipe_config + 4]
    call close@PLT
.Lcurl_setup_fail:
    lea rdi, [rip + error_buf]
    lea rsi, [rip + curl_start_error]
    call strcpy@PLT
    mov eax, 1
.Lcurl_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
.size call_gemini, .-call_gemini

.type parse_gemini_response, @function
parse_gemini_response:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    lea rdi, [rip + gemini_response]
    lea rsi, [rip + json_text_key]
    call strstr@PLT
    test rax, rax
    jz .Lparse_api_error
    mov rdi, rax
    mov esi, ':'
    call strchr@PLT
    test rax, rax
    jz .Lparse_api_error
    inc rax
.Lskip_text_space:
    movzx ecx, byte ptr [rax]
    cmp cl, ' '
    je .Ltext_space_next
    cmp cl, 9
    je .Ltext_space_next
    cmp cl, 10
    je .Ltext_space_next
    cmp cl, 13
    je .Ltext_space_next
    jmp .Ltext_value
.Ltext_space_next:
    inc rax
    jmp .Lskip_text_space
.Ltext_value:
    cmp byte ptr [rax], '"'
    jne .Lparse_api_error
    mov rdi, rax
    lea rsi, [rip + answer_raw]
    mov edx, 65536
    call decode_json_string
    test rax, rax
    jz .Lparse_api_error
    jmp .Lparse_done

.Lparse_api_error:
    lea rdi, [rip + gemini_response]
    lea rsi, [rip + json_message_key]
    call strstr@PLT
    test rax, rax
    jz .Lparse_generic_error
    mov rdi, rax
    mov esi, ':'
    call strchr@PLT
    test rax, rax
    jz .Lparse_generic_error
    inc rax
.Lskip_message_space:
    movzx ecx, byte ptr [rax]
    cmp cl, ' '
    je .Lmessage_space_next
    cmp cl, 9
    je .Lmessage_space_next
    cmp cl, 10
    je .Lmessage_space_next
    cmp cl, 13
    je .Lmessage_space_next
    jmp .Lmessage_value
.Lmessage_space_next:
    inc rax
    jmp .Lskip_message_space
.Lmessage_value:
    cmp byte ptr [rax], '"'
    jne .Lparse_generic_error
    mov rdi, rax
    lea rsi, [rip + error_buf]
    mov edx, 4096
    call decode_json_string
    test rax, rax
    jnz .Lparse_done

.Lparse_generic_error:
    lea rdi, [rip + error_buf]
    lea rsi, [rip + request_failed_error]
    call strcpy@PLT
.Lparse_done:
    leave
    ret
.size parse_gemini_response, .-parse_gemini_response

.type decode_json_string, @function
# rdi = opening quote, rsi = destination, rdx = destination capacity
# Returns decoded byte count. Unicode escapes, including surrogate pairs, are
# converted to UTF-8; all writes leave room for a trailing NUL.
decode_json_string:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    mov qword ptr [rbp - 8], rdi
    mov qword ptr [rbp - 16], rsi
    mov qword ptr [rbp - 24], rdx
    mov qword ptr [rbp - 32], 0
    mov qword ptr [rbp - 40], 0
    mov qword ptr [rbp - 48], 0
    cmp rdx, 1
    jbe .Ldecode_done
    inc qword ptr [rbp - 8]
.Ldecode_loop:
    mov rax, qword ptr [rbp - 8]
    movzx eax, byte ptr [rax]
    test al, al
    jz .Ldecode_done
    cmp al, '"'
    je .Ldecode_done
    cmp al, '\\'
    je .Ldecode_escape
    mov r10d, eax
    inc qword ptr [rbp - 8]
    jmp .Ldecode_emit

.Ldecode_escape:
    inc qword ptr [rbp - 8]
    mov rax, qword ptr [rbp - 8]
    movzx eax, byte ptr [rax]
    test al, al
    jz .Ldecode_done
    cmp al, 'u'
    je .Ldecode_unicode
    inc qword ptr [rbp - 8]
    cmp al, '"'
    je .Ldecode_simple
    cmp al, '\\'
    je .Ldecode_simple
    cmp al, '/'
    je .Ldecode_simple
    cmp al, 'n'
    je .Ldecode_newline
    cmp al, 'r'
    je .Ldecode_return
    cmp al, 't'
    je .Ldecode_tab
    cmp al, 'b'
    je .Ldecode_space
    cmp al, 'f'
    je .Ldecode_space
    jmp .Ldecode_loop
.Ldecode_simple:
    mov r10d, eax
    jmp .Ldecode_emit
.Ldecode_newline:
    mov r10d, 10
    jmp .Ldecode_emit
.Ldecode_return:
    mov r10d, 13
    jmp .Ldecode_emit
.Ldecode_tab:
    mov r10d, 9
    jmp .Ldecode_emit
.Ldecode_space:
    mov r10d, ' '
    jmp .Ldecode_emit

.Ldecode_unicode:
    inc qword ptr [rbp - 8]
    mov r8, qword ptr [rbp - 8]
    xor r10d, r10d
    mov ecx, 4
.Ldecode_hex4:
    movzx edi, byte ptr [r8]
    call hex_digit
    test eax, eax
    js .Ldecode_bad_unicode
    shl r10d, 4
    or r10d, eax
    inc r8
    dec ecx
    jnz .Ldecode_hex4
    mov qword ptr [rbp - 8], r8

    cmp r10d, 0xd800
    jb .Ldecode_unicode_valid
    cmp r10d, 0xdbff
    ja .Ldecode_check_low
    mov dword ptr [rbp - 48], r10d
    mov r11, qword ptr [rbp - 8]
    cmp byte ptr [r11], '\\'
    jne .Ldecode_replacement
    cmp byte ptr [r11 + 1], 'u'
    jne .Ldecode_replacement
    add r11, 2
    xor r10d, r10d
    mov ecx, 4
.Ldecode_low_hex4:
    movzx edi, byte ptr [r11]
    call hex_digit
    test eax, eax
    js .Ldecode_replacement
    shl r10d, 4
    or r10d, eax
    inc r11
    dec ecx
    jnz .Ldecode_low_hex4
    cmp r10d, 0xdc00
    jb .Ldecode_replacement
    cmp r10d, 0xdfff
    ja .Ldecode_replacement
    mov eax, dword ptr [rbp - 48]
    sub eax, 0xd800
    shl eax, 10
    mov edx, r10d
    sub edx, 0xdc00
    add eax, edx
    add eax, 0x10000
    mov r10d, eax
    mov qword ptr [rbp - 8], r11
    jmp .Ldecode_unicode_valid
.Ldecode_check_low:
    cmp r10d, 0xdfff
    jbe .Ldecode_replacement
.Ldecode_unicode_valid:
    test r10d, r10d
    jnz .Ldecode_emit
.Ldecode_replacement:
    mov r10d, 0xfffd
    jmp .Ldecode_emit
.Ldecode_bad_unicode:
    mov qword ptr [rbp - 8], r8
    mov r10d, 0xfffd

.Ldecode_emit:
    cmp r10d, 0x7f
    jbe .Ldecode_emit_one
    cmp r10d, 0x7ff
    jbe .Ldecode_emit_two
    cmp r10d, 0xffff
    jbe .Ldecode_emit_three
    jmp .Ldecode_emit_four
.Ldecode_emit_one:
    mov rax, qword ptr [rbp - 32]
    lea rdx, [rax + 1]
    cmp rdx, qword ptr [rbp - 24]
    jae .Ldecode_done
    mov rcx, qword ptr [rbp - 16]
    mov byte ptr [rcx + rax], r10b
    inc qword ptr [rbp - 32]
    jmp .Ldecode_loop
.Ldecode_emit_two:
    mov rax, qword ptr [rbp - 32]
    lea rdx, [rax + 2]
    cmp rdx, qword ptr [rbp - 24]
    jae .Ldecode_done
    mov rcx, qword ptr [rbp - 16]
    mov eax, r10d
    shr eax, 6
    or al, 0xc0
    mov byte ptr [rcx + rdx - 2], al
    mov eax, r10d
    and eax, 0x3f
    or al, 0x80
    mov byte ptr [rcx + rdx - 1], al
    add qword ptr [rbp - 32], 2
    jmp .Ldecode_loop
.Ldecode_emit_three:
    mov rax, qword ptr [rbp - 32]
    lea rdx, [rax + 3]
    cmp rdx, qword ptr [rbp - 24]
    jae .Ldecode_done
    mov rcx, qword ptr [rbp - 16]
    mov eax, r10d
    shr eax, 12
    or al, 0xe0
    mov byte ptr [rcx + rdx - 3], al
    mov eax, r10d
    shr eax, 6
    and eax, 0x3f
    or al, 0x80
    mov byte ptr [rcx + rdx - 2], al
    mov eax, r10d
    and eax, 0x3f
    or al, 0x80
    mov byte ptr [rcx + rdx - 1], al
    add qword ptr [rbp - 32], 3
    jmp .Ldecode_loop
.Ldecode_emit_four:
    mov rax, qword ptr [rbp - 32]
    lea rdx, [rax + 4]
    cmp rdx, qword ptr [rbp - 24]
    jae .Ldecode_done
    mov rcx, qword ptr [rbp - 16]
    mov eax, r10d
    shr eax, 18
    or al, 0xf0
    mov byte ptr [rcx + rdx - 4], al
    mov eax, r10d
    shr eax, 12
    and eax, 0x3f
    or al, 0x80
    mov byte ptr [rcx + rdx - 3], al
    mov eax, r10d
    shr eax, 6
    and eax, 0x3f
    or al, 0x80
    mov byte ptr [rcx + rdx - 2], al
    mov eax, r10d
    and eax, 0x3f
    or al, 0x80
    mov byte ptr [rcx + rdx - 1], al
    add qword ptr [rbp - 32], 4
    jmp .Ldecode_loop

.Ldecode_done:
    mov rax, qword ptr [rbp - 32]
    mov rcx, qword ptr [rbp - 16]
    mov byte ptr [rcx + rax], 0
    leave
    ret
.size decode_json_string, .-decode_json_string

.type escape_html, @function
# rdi = source, rsi = destination, rdx = destination capacity
# Returns the escaped byte count.
escape_html:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    xor r15d, r15d
    test r14, r14
    jz .Lhtml_return
.Lhtml_loop:
    movzx eax, byte ptr [r12]
    test al, al
    jz .Lhtml_finish
    mov r9d, eax
    lea r10, [rip + empty_string]
    xor r11d, r11d
    cmp al, '&'
    je .Lhtml_amp
    cmp al, '<'
    je .Lhtml_lt
    cmp al, '>'
    je .Lhtml_gt
    cmp al, '"'
    je .Lhtml_quote
    cmp al, '\''
    je .Lhtml_apostrophe
    jmp .Lhtml_plain
.Lhtml_amp:
    lea r10, [rip + html_amp]
    mov r11d, 5
    jmp .Lhtml_copy_entity
.Lhtml_lt:
    lea r10, [rip + html_lt]
    mov r11d, 4
    jmp .Lhtml_copy_entity
.Lhtml_gt:
    lea r10, [rip + html_gt]
    mov r11d, 4
    jmp .Lhtml_copy_entity
.Lhtml_quote:
    lea r10, [rip + html_quote]
    mov r11d, 6
    jmp .Lhtml_copy_entity
.Lhtml_apostrophe:
    lea r10, [rip + html_apos]
    mov r11d, 5
.Lhtml_copy_entity:
    lea rax, [r15 + r11]
    cmp rax, r14
    jae .Lhtml_finish
    mov rdi, r13
    add rdi, r15
    mov rsi, r10
    mov edx, r11d
    mov ebx, r11d
    call memcpy@PLT
    add r15, rbx
    inc r12
    jmp .Lhtml_loop
.Lhtml_plain:
    lea rax, [r15 + 1]
    cmp rax, r14
    jae .Lhtml_finish
    mov byte ptr [r13 + r15], r9b
    inc r15
    inc r12
    jmp .Lhtml_loop
.Lhtml_finish:
    mov byte ptr [r13 + r15], 0
.Lhtml_return:
    mov rax, r15
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
.size escape_html, .-escape_html

.section .rodata
html_amp:     .asciz "&amp;"
html_lt:      .asciz "&lt;"
html_gt:      .asciz "&gt;"
html_quote:   .asciz "&quot;"
html_apos:    .asciz "&#39;"

.section .text
.type build_grade_options, @function
build_grade_options:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi
    mov r13, rsi
    mov rdi, r12
    xor esi, esi
    mov edx, 2048
    call memset@PLT
    mov r14d, 1
.Lgrade_option_loop:
    lea rdi, [rip + grade_temp]
    mov esi, 64
    lea rdx, [rip + class_format]
    mov ecx, r14d
    xor eax, eax
    call snprintf@PLT
    mov rdi, r12
    call strlen@PLT
    mov r15, rax
    lea rdi, [rip + grade_temp]
    mov rsi, r13
    call strcmp@PLT
    lea r8, [rip + no_attr]
    test eax, eax
    jnz .Lgrade_not_selected
    lea r8, [rip + selected_attr]
.Lgrade_not_selected:
    lea rdi, [r12 + r15]
    mov esi, 2048
    sub rsi, r15
    lea rdx, [rip + grade_option_format]
    mov ecx, r14d
    mov r9d, r14d
    xor eax, eax
    call snprintf@PLT
    inc r14d
    cmp r14d, 13
    jl .Lgrade_option_loop
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
.size build_grade_options, .-build_grade_options

.type build_subject_options, @function
build_subject_options:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8
    mov r12, rdi
    mov r13, rsi
    mov rdi, r12
    xor esi, esi
    mov edx, 1024
    call memset@PLT
    xor r14d, r14d
.Lsubject_option_loop:
    lea rax, [rip + subject_items]
    mov r15, qword ptr [rax + r14*8]
    mov rdi, r12
    call strlen@PLT
    mov rbx, rax
    mov rdi, r15
    mov rsi, r13
    call strcmp@PLT
    lea r8, [rip + no_attr]
    test eax, eax
    jnz .Lsubject_not_selected
    lea r8, [rip + selected_attr]
.Lsubject_not_selected:
    lea rdi, [r12 + rbx]
    mov esi, 1024
    sub rsi, rbx
    lea rdx, [rip + subject_option_format]
    mov rcx, r15
    mov r9, r15
    xor eax, eax
    call snprintf@PLT
    inc r14d
    cmp r14d, 6
    jl .Lsubject_option_loop
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
.size build_subject_options, .-build_subject_options

.type build_page, @function
build_page:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    lea rdi, [rip + question_buf]
    lea rsi, [rip + question_html]
    mov edx, 49152
    call escape_html
    lea rdi, [rip + answer_raw]
    lea rsi, [rip + answer_html]
    mov edx, 131072
    call escape_html
    lea rdi, [rip + error_buf]
    lea rsi, [rip + error_html]
    mov edx, 24576
    call escape_html

    lea rdi, [rip + grade_options_buf]
    lea rsi, [rip + grade_buf]
    call build_grade_options
    lea rdi, [rip + subject_options_buf]
    lea rsi, [rip + subject_buf]
    call build_subject_options

    lea rdi, [rip + result_html_buf]
    xor esi, esi
    mov edx, 160000
    call memset@PLT
    cmp byte ptr [rip + answer_raw], 0
    je .Lpage_not_answer
    lea rdi, [rip + result_html_buf]
    mov esi, 160000
    lea rdx, [rip + answer_result_format]
    lea rcx, [rip + answer_html]
    xor eax, eax
    call snprintf@PLT
    jmp .Lpage_result_ready
.Lpage_not_answer:
    cmp byte ptr [rip + error_buf], 0
    je .Lpage_empty
    lea rdi, [rip + result_html_buf]
    mov esi, 160000
    lea rdx, [rip + error_result_format]
    lea rcx, [rip + error_html]
    xor eax, eax
    call snprintf@PLT
    jmp .Lpage_result_ready
.Lpage_empty:
    lea rdi, [rip + result_html_buf]
    lea rsi, [rip + empty_result_html]
    call strcpy@PLT
.Lpage_result_ready:

    lea rdi, [rip + page_buf]
    xor esi, esi
    mov edx, 262144
    call memset@PLT
    APPEND html_start
    APPEND html_styles
    APPEND grade_options_buf
    APPEND html_grade_to_subject
    APPEND subject_options_buf
    APPEND html_subject_to_question
    APPEND question_html
    APPEND html_question_to_button
    APPEND result_html_buf
    APPEND html_page_end

    leave
    ret
.size build_page, .-build_page

.type write_full, @function
# fd in edi, data in rsi, byte count in rdx. Returns zero on success.
write_full:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov dword ptr [rbp - 4], edi
    mov qword ptr [rbp - 16], rsi
    mov qword ptr [rbp - 24], rdx
.Lwrite_full_loop:
    cmp qword ptr [rbp - 24], 0
    je .Lwrite_full_ok
    mov edi, dword ptr [rbp - 4]
    mov rsi, qword ptr [rbp - 16]
    mov rdx, qword ptr [rbp - 24]
    xor ecx, ecx
    call send@PLT
    test rax, rax
    jle .Lwrite_full_error
    add qword ptr [rbp - 16], rax
    sub qword ptr [rbp - 24], rax
    jmp .Lwrite_full_loop
.Lwrite_full_ok:
    xor eax, eax
    leave
    ret
.Lwrite_full_error:
    mov eax, -1
    leave
    ret
.size write_full, .-write_full

.section .bss
.align 8
grade_temp: .zero 64

.section .note.GNU-stack,"",@progbits
