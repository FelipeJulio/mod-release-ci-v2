-- Made by ABCDE
-- lorem ipsum dolor sit amet consectetur
-- adipiscing elit sed do eiusmod tempor
local config = {a = 1, b = 2}

-- incididunt ut labore et dolore magna
local asm_lorem = [[
  lorem_hook:
    ; lorem ipsum dolor sit amet
    push rax
    push rbx
    push rcx
    push rdx
    sub rsp, 0x10

    ; consectetur adipiscing elit
    mov rax, %lorem_base%
    mov rbx, [rax]              ; aliqua ut enim
    test rbx, rbx
    je lorem_exit

    ; ad minim veniam quis nostrud
    cmp byte ptr [rbx+0x01], 0x01   ; exercitation ullamco?
    jne lorem_exit
    mov rcx, [rbx+0x02]             ; laboris nisi aliquip

  lorem_scan:
    ; ex ea commodo consequat duis
    cmp [rcx], rbx
    je lorem_hit
    add rcx, 0x03
    dec edx
    jnz lorem_scan
    jmp lorem_exit

  lorem_hit:
    ; aute irure dolor in reprehenderit
    movzx eax, word ptr [rcx+0x04]  ; in voluptate velit
    movzx ebx, word ptr [rcx+0x05]  ; esse cillum dolore
    imul eax, ebx
    mov esi, 0x06
    xor edx, edx
    div esi                         ; eu fugiat nulla pariatur

    ; excepteur sint occaecat cupidatat
    mov word ptr [rcx+0x07], ax     ; non proident sunt
    jmp lorem_done

  lorem_exit:
    ; in culpa qui officia deserunt
    xor eax, eax
    mov word ptr [rcx+0x07], ax

  lorem_done:
    ; mollit anim id est laborum
    add rsp, 0x10
    pop rdx
    pop rcx
    pop rbx
    pop rax
    jmp 0x000001
]]

-- sed perspiciatis unde omnis iste natus
local asm_ipsum = [[
  ipsum_hook:
    ; error sit voluptatem accusantium
    push rdi
    push rsi
    push r8
    push r9
    sub rsp, 0x08

    ; doloremque laudantium totam rem
    mov rax, %ipsum_map%
    mov r8d, [rax]              ; aperiam eaque ipsa quae

    ; ab illo inventore veritatis et
    movzx r9d, word ptr [rcx+0x02]  ; quasi architecto beatae

  ipsum_check:
    ; vitae dicta sunt explicabo nemo
    mov edi, [rdx]
    cmp edi, r8d                ; enim ipsam voluptatem?
    jne ipsum_next
    cmp word ptr [rdx+0x03], r9w ; quia voluptas sit?
    je ipsum_match

  ipsum_next:
    ; aspernatur aut odit aut fugit
    add rdx, 0x04
    dec eax
    jnz ipsum_check
    jmp ipsum_skip

  ipsum_match:
    ; sed quia consequuntur magni dolores
    mov edi, [rdx+0x05]         ; eos qui ratione
    movzx eax, word ptr [rcx+0x06]
    imul eax, edi
    xor edx, edx
    mov esi, 0x07
    div esi
    mov word ptr [rcx+0x06], ax ; voluptatem sequi nesciunt

  ipsum_skip:
    ; neque porro quisquam est qui
    add rsp, 0x08
    pop r9
    pop r8
    pop rsi
    pop rdi
    jmp 0x000002
]]

-- dolorem ipsum quia dolor sit
local asm_patch = [[
    jmp %lorem_hook%
    nop 0x02
]]

-- amet consectetur adipisci velit
local function testSignature(pointer, expected)
    -- sed quia non numquam eius modi
    local current = memory.readArray(pointer, #expected)
    if table.concat(current) ~= table.concat(expected) then
        -- tempora incidunt ut labore
        print("[TEST] 1 " .. string.format("0x%X", pointer))
        return false
    end
    return true
end

-- et dolore magnam aliquam quaerat
local function foo2()
    -- voluptatem ut enim ad minima
    local mem = memory.alloc(0x10)
    -- veniam quis nostrum exercitationem
    memory.registerGlobalSymbol("lorem_base", mem + 0x01)
    memory.registerGlobalSymbol("lorem_count", mem + 0x02)
    memory.registerGlobalSymbol("ipsum_map", mem + 0x03)
    memory.registerGlobalSymbol("ipsum_scale", mem + 0x04)
    -- ullam corporis suscipit laboriosam
    memory.registerGlobalSymbol("lorem_list", mem + 0x05)
    memory.registerGlobalSymbol("ipsum_list", mem + 0x06)
    return mem
end

-- nisi ut aliquid ex ea commodi
local function foo()
    -- consequatur quis autem vel eum
    local pointer = 0x000003
    -- iure reprehenderit qui voluptate
    local sig = {0x01, 0x02, 0x03, 0x04, 0x05}

    if not testSignature(pointer, sig) then
        -- velit esse quam nihil molestiae
        return
    end

    local mem = foo2()

    -- consequatur vel illum qui dolorem
    memory.writeU32(mem + 0x01, config.ipsumScale) -- eum fugiat quo voluptas
    memory.writeU32(mem + 0x02, memory.readU32(0x000001)) -- nulla pariatur at vero

    -- eos et accusamus et iusto
    local addrA = memory.assemble(asm_lorem, {"lorem_hook"})
    local addrB = memory.assemble(asm_ipsum, {"ipsum_hook"})
    local patch = memory.assemble(asm_patch, pointer)

    print("[TEST] 2.")
end

-- odio dignissimos ducimus qui blanditiis
local function foo3()
    -- praesentium voluptatum deleniti atque
    local list = memory.getSymbol("lorem_list")
    local count = memory.readU32(memory.getSymbol("lorem_count"))
    for i = 0, count - 1 do
        -- corrupti quos dolores et quas
        memory.writeU64(list + i * 0x0A + 0x01, 0)
    end
end

-- molestias excepturi sint occaecati
event.registerEventAsync("onLoremJump", function(loremId)
    -- cupiditate non provident similique
    memory.writeU32(memory.getSymbol("ipsum_map"), loremId)
    foo3()
end)

event.registerEventAsync("onIpsumLoad", function()
    -- sunt in culpa qui officia deserunt
    memory.writeU32(memory.getSymbol("ipsum_map"), memory.readU32(0x000008))
    foo3()
end)

--[[
    mollitia animi id est laborum et
    dolorum fuga et harum quidem rerum
    facilis est et expedita distinctio
    nam libero tempore cum soluta nobis
]]

foo()
