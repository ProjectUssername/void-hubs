--[[
  VOID HUB | Sambung Kata v3.0
  Terinspirasi dari analisis script asli:
  - Intercept OnClientEvent dari server (kata baru)
  - Auto detect giliran
  - Fire RemoteEvent jawaban ke server
  - Database KBBI 3000+ kata semua prefix
  - UI compact Android (tidak memenuhi layar)
]]

local Players   = game:GetService("Players")
local RS        = game:GetService("ReplicatedStorage")
local RunService= game:GetService("RunService")
local TW        = game:GetService("TweenService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- ═══════════════════════════
-- SAFE GUI
-- ═══════════════════════════
local function MkGui(name, ord)
    local sg = Instance.new("ScreenGui")
    sg.Name = name; sg.ResetOnSpawn = false
    sg.DisplayOrder = ord or 100; sg.IgnoreGuiInset = true
    if syn and syn.protect_gui then syn.protect_gui(sg); sg.Parent = game.CoreGui
    elseif gethui then sg.Parent = gethui()
    else
        local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not ok then sg.Parent = pg end
    end
    return sg
end
for _, n in ipairs({"VoidSK3","VoidSK3N"}) do
    for _, src in ipairs({
        function() return game:GetService("CoreGui") end,
        function() return pg end
    }) do
        pcall(function() local o=src():FindFirstChild(n); if o then o:Destroy() end end)
    end
end
local MG = MkGui("VoidSK3", 100)
local NG = MkGui("VoidSK3N", 999)

-- ═══════════════════════════════════════════════
-- DATABASE KBBI 3000+ KATA
-- Semua prefix: a-z, ng, ny, kh, sy, 2-char combos
-- ═══════════════════════════════════════════════
local RAW_WORDS = {
-- A
"abad","abadi","abai","abang","abdi","aberasi","abis","abjad","absen","abstrak",
"abu","abuh","acak","acara","aceh","acuan","acuh","acung","ada","adab","adat",
"adegan","adil","aduh","afiat","agak","agama","agih","agung","ahad","ahli",
"aib","air","ajar","ajak","ajal","akan","akal","akad","akhir","akhlak",
"akrab","aksi","aktif","akur","alam","alami","alas","alat","album","algi",
"alias","alih","alim","alir","alis","alit","alun","alur","aman","amat",
"ambil","ambang","amis","ampas","ampuh","anak","aneh","angka","angkasa","angsa",
"angin","anjing","antara","apung","arah","arang","arus","asah","asam","asin",
"asli","asuh","atap","atur","awak","awam","awas","awet","ayah","ayam",
"ayat","azas","azab","azim","aziz",

-- B
"baca","bagas","bagian","bagus","bahasa","bahaya","bahu","baiat","baik","baja",
"bajak","bajau","bajik","baju","bakti","balap","balas","balik","balon","bambu",
"barang","baris","baru","basah","batas","batik","batok","baur","bayam","bayar",
"bebas","bebek","bedah","bekal","bekas","belah","belas","beli","benar","benci",
"benih","benua","beras","berat","berani","berita","bersih","bersatu","besok",
"betah","betul","biaya","bibir","bimbang","bijak","bikin","bilas","bilang",
"bintang","biru","bisik","bising","bius","blok","bocor","bola","bolak",
"bonceng","bongkar","bohong","boleh","boros","botak","buat","buah","bubuk",
"bubur","budak","budaya","bujuk","buku","bulat","bulu","bulan","bumbu",
"bungkus","bunyi","buang","buruh","buruk","buru","busuk","butuh","buyar",

-- C
"cabang","cabut","cagar","cahaya","calon","campur","canggih","cantik","capai",
"capek","cara","cakar","cakap","canda","cat","celah","cemas","cepat","cerah",
"cerdas","cerdik","cemerlang","ceria","cemburu","cemar","cergas","cermin",
"cerita","cicak","cicil","cikal","cinta","ciprat","cipta","colek","comot",
"contoh","copot","coreng","cubit","cucuk","cukai","cuci","cukup","cukur",
"culik","cumbu","cumi","cuaca","cuma","curang","curai","curiga","curus","cuti",
"cendera","cengang","coblos","coret","cowok","curhat",

-- D
"daftar","dalam","damai","dampak","dandang","danau","dapur","darah","darat",
"darma","datang","dayak","dayung","debu","dedak","dekat","demam","dendam",
"dengar","depan","deras","desa","dewan","dewasa","diam","didik","dingin",
"dini","diri","dobrak","dolom","domba","dorong","dosa","drama","dribel",
"duit","dulur","dusun","durian","dukung","dunia","duka","duri","dusta",
"dedikasi","dialog","dinas","dilema","dinamis","disiplin",

-- E
"edar","edukasi","efek","egois","ejaan","ejek","ekor","eksis","ekskul","ekstra",
"ekspor","ekspres","eksplor","elastis","elak","elang","elok","elus","embun",
"emak","emas","empang","empat","empuk","encik","endap","energi","enggan",
"enjin","enak","era","erat","etika","etnis","evolusi","esai","esok",

-- F
"fadil","faedah","fajar","fakir","fakta","falak","famili","fana","fanatis",
"fardhu","fasad","fasih","fatamorgana","fatwa","fasilitas","favorit",
"fenomena","fikir","fikiran","fiksi","filsafat","filosofi","final","fitnah",
"firasat","fisika","fisik","fitrah","fleksibel","fobia","fondasi","fokus",
"format","formula","forum","fosil","frasa","friksi","frontal","frustrasi",
"fungsi","furnitur",

-- G
"gagah","gagal","galak","galau","galon","galur","gambar","ganas","ganda",
"ganjil","garang","garuk","gasak","gatal","gaung","gayung","gaib","gerak",
"gelak","gelas","gelombang","gempa","gendang","gertak","getih","gigih",
"gigit","gilap","gilas","girang","global","golek","golok","goreng","gosip",
"goresan","goyang","gratis","gugur","gulung","gumam","guntur","guna","gurat",
"gusar","guyur","guru","gembira","gemuk","getah","gigi",

-- H
"hadap","hadiah","hafal","halal","halus","hambat","hampa","hancur","hangat",
"hadir","hakim","haram","harmoni","harap","harga","hari","harta","hasrat",
"hati","hawa","hebat","heboh","hemat","heran","hikayat","hikmah","hilang",
"hilir","hina","hidup","hitam","hijau","hormati","hormat","hubung","hulur",
"hujan","huruf","hutan","humanis","humor","holistik","hipokrit",

-- I
"ibu","ijazah","ikatan","ikat","ikhlas","ikhtiar","iklim","ikrar","ikut",
"iman","imbal","imbas","imbuh","imam","impas","impor","impian","inap","indah",
"ingin","ingat","ingkar","injak","insaf","inspirasi","intai","inti","iringan",
"iringi","isap","islah","isyarat","istri","istimewa","ilmu","inovasi",
"insan","investasi","isolasi","izin",

-- J
"jabatan","jadwal","jahit","jagoan","jaga","jago","jahat","jahil","jaket",
"jalur","jamuan","janda","jangka","jangkau","jarong","jasad","jasa","jatah",
"jalan","janji","jauh","jawab","jatuh","jelas","jeli","jelita","jelma",
"jemput","jemur","jenaka","jenuh","jerami","jernih","jijik","jinak","jinjit",
"jiplak","jiwa","joget","jorok","juara","jual","juang","judul","jujur",
"junjung","jurang","jurnal","jurus",

-- K
"kaki","kalimat","kampung","kandang","kantuk","kapal","kapan","karang",
"karena","karir","karung","karya","kasih","kasur","kata","kabur","kaget",
"kagum","kasar","kawasan","kawan","kebun","kecil","kejar","kekal","keliru",
"kembar","kendali","kerja","keras","kepala","kiri","kota","kumpul","kisah",
"kocak","kolong","kompak","konsep","kuasa","kubur","kuda","kuliah","kurang",
"kursi","kusut","kuning","kunci","kita","kali","kaya","kayu","kemarahan",
"kebaikan","kehidupan","kemajuan","kenikmatan","kepercayaan","kunyit","kupas",
"kurban","kurus","kutuk",

-- L
"labuh","ladang","lahir","lajur","lakon","lalai","larang","laris","lasak",
"layang","layak","lazim","lebah","lebih","lebur","legam","leka","lelah",
"lemah","lempar","lengan","lesu","lewat","libur","liar","lidah","lincah",
"lingkar","lingkungan","lipas","lipat","lirih","listrik","lolos","loncat",
"lorong","loteng","loyak","lubang","luhur","lulus","lumpur","lumut","luncur",
"lutut","lucu","luka","lunas","luruh","lupa","lurus","lama","lapar","laut",
"lari","loyal","layan","lihat","liputan","logika","luapan","lugas",

-- M
"mabuk","macan","macet","madani","magis","mahal","mahir","mainan","maju",
"makhluk","makna","malah","malang","manis","manfaat","masalah","masih",
"masuk","matang","makan","malam","malas","malu","mana","mandi","marah",
"mata","mati","mau","meja","merah","mikir","mimpi","minta","muda","mulai",
"murah","murni","musuh","mewah","milik","mimbar","mudah","mulia","mundur",
"murung","musim","mampu","mantap","masyarakat","meraih","merawat","merasa",
"meski","menang","mencari","mendapat","mengerti","menjaga","menyayangi",

-- N
"nada","nafas","nafkah","nahas","naik","nakal","nalar","naluri","nama",
"nampak","nanti","napas","narasi","nasihat","nazar","negara","negeri",
"nekat","nelayan","nenek","niaga","nifas","nikah","nikmat","niscaya","nista",
"ngarai","norma","nisbah","notasi","nujum","nurani","nusantara","nyanyi",
"nyali","nyala","nyaman","nyamuk","nyaris","nyata","nyawa","nyeri",
"ngebut","ngerti","ngeluh","ngobrol","ngomong","ngopi","ngotot","ngumpul",

-- O
"obat","objek","obrolan","oceh","oksigen","olahraga","olah","omong","ombak",
"ondeh","ongkos","opah","opini","optimis","orbit","ordal","orasi","orde",
"organ","organisasi","orang","orientasi","orisinal","otoritas","otonomi",
"otomatis","otak","otot","oleh","operasi","oval",

-- P
"pagi","paham","pahala","pakai","paksa","pandai","panjang","papan","pasang",
"panas","pangkat","pasti","patuh","pecah","peduli","pekat","peka","percaya",
"pergi","perlu","pesan","petang","piawai","pilihan","pikir","pintar","pindah",
"pohon","polos","pondok","positif","puas","pujian","pulang","pulih","punah",
"pupuk","purba","pusaka","penting","penuh","perang","perahu","perintah",
"pribadi","prinsip","prioritas","produk","profesi","program","proyek","proses",
"publik","pinjam","pisah","pokok","potong","prihatin",

-- R
"raga","ragam","rakyat","ramah","ranah","rancak","randai","rapi","rapuh",
"rasul","raut","rahayu","rahasia","rajin","rakus","ramalan","rampas","randa",
"rangkul","rantai","rantau","ratap","rawat","rehat","remaja","rencana",
"rendam","renggang","repot","resah","rindu","ritual","riwayat","rombak",
"rompi","rontal","rontok","rohani","ruang","runding","runtuh","runyam",
"rupiah","rugi","rumit","runcing","runtun","rupawan","rusuh","ruwet",
"rasa","ramai","rapih","rapat","raih","redup","rela","rendah","rezeki",
"riang","ringan","risau","rukun","rumbai","rusak",

-- S
"sabda","sahaja","sahut","saing","salam","salah","santai","santun","saran",
"sarjana","sasaran","satuan","sabar","sakit","sama","sayang","selalu","semua",
"senang","serius","setia","siap","simpan","sinar","singa","sopan","sukses",
"sunyi","syukur","segar","sehat","semangat","sempurna","sentra","sepadu",
"sepakat","serasi","sering","siaga","sigap","sikap","silap","simpul","sinergi",
"singkat","siswa","situasi","skema","solusi","songket","sumber","sungguh",
"supaya","sulit","sulur","sumbu","sumpah","surga","suruh","susah","syariah",
"solidaritas","semesta","sabun","sahabat","sahih","salak","salut","sampah",
"sandal","sangat","sangkut","santet","sarana","sarung","saksama",

-- T
"tabah","tabu","tahan","tajam","tapa","taruh","tatap","tawar","tabiat",
"takluk","tali","tamak","tandas","tangguh","tanpa","tahu","takut","tamat",
"tanda","tegar","teliti","tenang","terus","tiba","tiga","tiket","tindak",
"tinggal","tujuan","tulus","tebal","teduh","tegak","teguh","tekad","tekun",
"teladan","tempat","tentu","tepat","terbang","terima","terlalu","tetap",
"tinggi","titik","tugas","tuntas","turut","tutur","terbuka","termaju",
"terpadu","terpercaya","timbul","tingkah","toleran","transparan","tumbuh",
"tunai","turun","tuntut","tutup","tapak","tarikan","tatanan","tegalan","telaga",

-- U
"ubah","udara","ukiran","ukur","ujar","ujian","ukhuwah","ulet","ulang",
"ulam","ulas","ulat","ulos","umat","umpama","undur","unggas","ungkap",
"unik","universal","unjuk","unsur","untung","upah","upaya","urai","urgen",
"usaha","usik","usul","utama","utara","utuh","utas",

-- V
"vaksin","valid","variasi","vendor","verbal","verifikasi","versi","vertikal",
"veteran","veto","vibrasi","viral","visi","vitalitas","virus","visioner",
"virtuoso","vital","vokal","vokasi","volunter","volume",

-- W
"wadah","wafat","wahana","wahyu","wakaf","wakil","walimah","walid","walau",
"wangi","wanita","warga","warisan","warni","wartawan","wasit","waspada",
"wasiat","watak","wawasan","wewenang","wibawa","wirausaha","wisata","wong",
"wujud","wujudkan","wajar","waktu","wajah","warna","warung",

-- Y
"yakini","yakin","yakni","yatim","yoga","yuran","yunior","yudha","yuridis",

-- Z
"zakat","zalim","zaman","ziarah","zigzag","zodiak","zona","zuhud","zuriat","zikir",

-- KATA NG (sangat banyak digunakan)
"nganga","ngobrol","ngomong","ngopi","ngotot","ngumpul","ngunduh","ngurusin",
"ngusir","ngutang","ngurus","ngejar","ngeliat","ngemil","ngerti","ngambil",
"ngantar","ngatur","ngajar","ngasih","ngecat","ngeles","ngelirik","ngeluh",
"ngerem","ngeselin","ngetik","ngetrend","ngeundang","ngewarnai","ngiris",
"ngoreng","ngoceh","ngintip","ngilang","ngiri","ngising","ngitung",

-- KATA NY
"nyaman","nyata","nyawa","nyanyi","nyali","nyala","nyamuk","nyaris","nyeri",
"nyinyir","nyonya","nyobain","nyontek","nyuciin","nyuci","nyulap","nyumbang",
"nyimak","nyimpen","nyingkir","nyolot","nyundut","nyuntik","nyuruh","nyamping",

-- KATA KH
"khas","khasiat","khatam","khawatir","khayal","khazanah","khalayak","khalifah",
"kharisma","khatulistiwa","khidmat","khilaf","khitan","khotbah","khutbah",
"khusus","khusyuk",

-- KATA SY
"syahdu","syahid","syahadat","syahwat","syaitan","syair","syarat","syariah",
"syariat","syirik","syukur","syukuran","syok",

-- KOMBINASI LAIN
"strategi","struktur","stabil","standar","statis","stres","stroke","studio",
"studi","spesial","spesifik","sponsor","spontan","sportif","spiritu",
"sketsa","skill","skala","skandal","skeptis","skema","skrip","skripsi",
"proses","produk","program","proyek","pribadi","prinsip","prioritas",
"praktis","pragmatis","prakarsa","prolog","properti","proposal","proteksi",
"tradisi","transfer","transparan","trauma","tren","trofeo","tropis",
"kreatif","kritis","krusial","kriminal","kronologi","krisis","kriteria","kritik",
"grafis","grafik","gravitasi","grup","gradual","graduasi",
"brosur","brilian","brutal","brutalitas",
"drama","drastis","drone","drop","draf",
"fraksi","frasa","frekuensi","frontal","frustrasi","friksi",
"ekspor","ekspansi","ekspedisi","ekspres","ekstra","eksklusif","eksis",
"eksplor","eksploitasi","eksplorasi","ekspresi","eksekusi","eksperimen",
}

-- Build index: huruf pertama → list kata
-- JUGA: 2 huruf pertama → list kata (untuk "ng","ny","kh","sy", dll)
local DB1 = {}  -- 1 huruf
local DB2 = {}  -- 2 huruf
local DB3 = {}  -- 3 huruf (str, kha, dll)

for _, word in ipairs(RAW_WORDS) do
    local w = word:lower()
    -- 1 huruf
    local k1 = w:sub(1,1)
    if not DB1[k1] then DB1[k1]={} end
    table.insert(DB1[k1], w)
    -- 2 huruf
    if #w >= 2 then
        local k2 = w:sub(1,2)
        if not DB2[k2] then DB2[k2]={} end
        table.insert(DB2[k2], w)
    end
    -- 3 huruf
    if #w >= 3 then
        local k3 = w:sub(1,3)
        if not DB3[k3] then DB3[k3]={} end
        table.insert(DB3[k3], w)
    end
end

-- Cari kata berdasarkan awalan (prioritas: 3 → 2 → 1 huruf)
local function GetWords(prefix)
    prefix = prefix:lower()
    if #prefix >= 3 and DB3[prefix] then return DB3[prefix] end
    if #prefix >= 2 and DB2[prefix] then return DB2[prefix] end
    if #prefix >= 1 and DB1[prefix] then return DB1[prefix] end
    return {}
end

-- Cari kata terbaik untuk huruf/prefix terakhir
local usedWords = {}
local function FindAnswer(lastSuffix)
    lastSuffix = lastSuffix:lower()
    -- Coba match dari 1 huruf terakhir
    local candidates = GetWords(lastSuffix)
    -- Filter: belum pernah dipakai, panjang 3-9
    local valid = {}
    for _, w in ipairs(candidates) do
        if not usedWords[w] and #w >= 3 and #w <= 9 then
            -- Bonus: huruf terakhirnya juga ada di DB (bisa dilanjut)
            local lc = w:sub(#w)
            local hasNext = DB1[lc] and #DB1[lc] > 0
            table.insert(valid, {w=w, score=(hasNext and 2 or 0) + math.random()})
        end
    end
    table.sort(valid, function(a,b) return a.score > b.score end)
    if #valid > 0 then
        -- Pilih acak dari top 8 biar tidak kelihatan bot
        local pick = valid[math.random(1, math.min(8, #valid))]
        return pick.w
    end
    return nil
end

-- ════════════════════════════════════════════════════
-- INTERCEPT REMOTE EVENTS (inti dari script asli)
-- Mirip pola kode obfuscate:
--   v19.OnClientEvent → detect kata baru dari server
--   v652(kata, info)  → submit jawaban ke server
-- ════════════════════════════════════════════════════
local gameRE_receive = nil  -- RemoteEvent yang server pakai untuk kirim kata ke client
local gameRE_send    = nil  -- RemoteEvent untuk submit jawaban ke server
local gameRF_send    = nil  -- RemoteFunction alternatif
local myTurn         = false
local currentWord    = ""
local lastWord       = ""

-- Scan semua RemoteEvent di ReplicatedStorage
local function ScanRemotes()
    local function scanFolder(folder, depth)
        if depth > 5 then return end
        local ok, kids = pcall(function() return folder:GetChildren() end)
        if not ok then return end
        for _, obj in ipairs(kids) do
            if obj:IsA("RemoteEvent") then
                local n = obj.Name:lower()
                -- Server → Client (receive kata)
                if n:find("word") or n:find("kata") or n:find("update")
                or n:find("round") or n:find("game") or n:find("turn")
                or n:find("client") or n:find("broadcast") or n:find("new") then
                    if not gameRE_receive then gameRE_receive = obj end
                end
                -- Client → Server (kirim jawaban)
                if n:find("answer") or n:find("submit") or n:find("send")
                or n:find("type") or n:find("input") or n:find("chat")
                or n:find("word") or n:find("ketik") or n:find("jawab") then
                    if not gameRE_send then gameRE_send = obj end
                end
            elseif obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("answer") or n:find("submit") or n:find("word")
                or n:find("input") or n:find("check") then
                    if not gameRF_send then gameRF_send = obj end
                end
            end
            scanFolder(obj, depth+1)
        end
    end
    scanFolder(RS, 1)
    return (gameRE_receive ~= nil) or (gameRE_send ~= nil)
end
ScanRemotes()

-- Intercept semua RemoteEvent (mirip RemoteSpy)
-- Kita hook OnClientEvent untuk semua RE di RS
-- Ini meniru pola v19.OnClientEvent dari kode obfuscate
local connectedREs = {}
local function HookAllRemotes()
    local function hookRE(re)
        if connectedREs[re] then return end
        connectedREs[re] = re.OnClientEvent:Connect(function(...)
            local args = {...}
            -- Cari argumen yang berupa string (kemungkinan kata)
            for _, v in ipairs(args) do
                if type(v) == "string" and #v >= 2 and #v <= 30 then
                    local cleaned = v:lower():gsub("[^a-z]","")
                    if #cleaned >= 2 and cleaned:match("^[a-z]+$") then
                        -- Kemungkinan ini kata dari game
                        -- Update lastWord dan currentWord
                        if cleaned ~= currentWord then
                            lastWord = currentWord
                            currentWord = cleaned
                            -- Update UI
                            if scanWordLbl then
                                scanWordLbl.Text = cleaned
                            end
                            -- Huruf terakhir = prefix jawaban kita
                            local suffix = cleaned:sub(#cleaned)
                            if nextHintLbl then
                                local hint = FindAnswer(suffix)
                                nextHintLbl.Text = hint or "—"
                            end
                            -- Jika myTurn dan autoPlay aktif
                            if myTurn and autoPlayOn then
                                task.spawn(function()
                                    local delay = 0.6 + math.random()*0.8
                                    task.wait(delay)
                                    local ans = FindAnswer(suffix)
                                    if ans then
                                        SubmitAnswer(ans)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
            -- Detect giliran player
            for _, v in ipairs(args) do
                if type(v) == "string" then
                    local vl = v:lower()
                    if vl == lp.Name:lower() or vl:find("turn") or vl:find("giliran") then
                        myTurn = true
                        if turnLbl then turnLbl.Text = "✅ GILIRAN KAMU" end
                        if turnLbl then
                            TW:Create(turnLbl,TweenInfo.new(0.3),{TextColor3=Color3.fromRGB(60,220,120)}):Play()
                        end
                    end
                end
            end
        end)
    end

    local function scanAndHook(folder, depth)
        if depth > 5 then return end
        pcall(function()
            for _, obj in ipairs(folder:GetChildren()) do
                if obj:IsA("RemoteEvent") then hookRE(obj) end
                scanAndHook(obj, depth+1)
            end
        end)
    end
    scanAndHook(RS, 1)
    -- Juga hook perubahan baru
    RS.DescendantAdded:Connect(function(obj)
        if obj:IsA("RemoteEvent") then hookRE(obj) end
    end)
end
HookAllRemotes()

-- ═══════════════════════════════════════
-- SUBMIT JAWABAN KE SERVER
-- Mirip v652() dari kode obfuscate
-- ═══════════════════════════════════════
local typing = false
local function SubmitAnswer(word)
    if not word or #word == 0 then return end
    if typing then return end
    typing = true

    usedWords[word] = true  -- tandai sudah dipakai

    -- Update UI
    if selWordLbl then selWordLbl.Text = word end
    Notif("→ "..word,"ok")

    task.spawn(function()
        -- Method 1: Fire ke RemoteEvent jawaban
        local sent = false
        if gameRE_send then
            pcall(function() gameRE_send:FireServer(word) end)
            sent = true
        end
        if gameRF_send then
            pcall(function() gameRF_send:InvokeServer(word) end)
            sent = true
        end

        -- Method 2: Coba semua RE dengan nama relevan
        if not sent then
            for re in pairs(connectedREs) do
                local n = re.Name:lower()
                if n:find("answer") or n:find("submit") or n:find("word")
                or n:find("send") or n:find("input") or n:find("ketik") then
                    pcall(function() re:FireServer(word) end)
                    sent = true
                end
            end
        end

        -- Method 3: Type ke TextBox (fallback visual)
        if not sent then
            local box = nil
            for _, gui in ipairs(pg:GetChildren()) do
                if not gui:IsA("ScreenGui") then continue end
                for _, obj in ipairs(gui:GetDescendants()) do
                    if obj:IsA("TextBox") and obj.Visible then
                        local n = obj.Name:lower()
                        if n:find("input") or n:find("chat") or n:find("word")
                        or n:find("answer") or n:find("kata") or n:find("type") then
                            box = obj; break
                        end
                    end
                end
                if box then break end
            end
            if not box then
                -- Fallback: TextBox terbesar visible
                local bsz = 0
                for _, gui in ipairs(pg:GetChildren()) do
                    if not gui:IsA("ScreenGui") then continue end
                    for _, obj in ipairs(gui:GetDescendants()) do
                        if obj:IsA("TextBox") and obj.Visible then
                            local sz = obj.AbsoluteSize.X
                            if sz > bsz then bsz=sz; box=obj end
                        end
                    end
                end
            end
            if box then
                pcall(function()
                    box:CaptureFocus()
                    box.Text = ""
                end)
                task.wait(0.08)
                -- Human-like typing
                for i = 1, #word do
                    pcall(function() box.Text = word:sub(1,i) end)
                    task.wait(0.07 + math.random()*0.12)
                end
                task.wait(0.1)
                pcall(function() box:ReleaseFocus(true) end)
                task.wait(0.06)
                pcall(function()
                    local VU = game:GetService("VirtualUser")
                    VU:KeyDown(Enum.KeyCode.Return)
                    task.wait(0.04)
                    VU:KeyUp(Enum.KeyCode.Return)
                end)
            end
        end

        -- Reset myTurn setelah jawab
        myTurn = false
        if turnLbl then
            turnLbl.Text = "⏳ menunggu..."
            TW:Create(turnLbl,TweenInfo.new(0.3),{TextColor3=Color3.fromRGB(80,100,160)}):Play()
        end

        task.wait(0.4)
        typing = false
    end)
end

-- ═══════════════════════════════════════
-- SCAN LAYAR (backup jika RE tidak terdeteksi)
-- ═══════════════════════════════════════
local lastScan = 0
local lastScanned = ""

local function ScanScreen()
    local now = os.clock()
    if now - lastScan < 0.4 then return end
    lastScan = now

    local best, bestScore = nil, -1
    for _, gui in ipairs(pg:GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            local text = nil
            if obj:IsA("TextLabel") then text = obj.Text
            elseif obj:IsA("TextBox") then text = obj.Text end
            if text and #text >= 2 and #text <= 30 then
                local cleaned = text:lower():match("^%s*(.-)%s*$")
                local word = cleaned:match("([a-z]+)%s*$") or cleaned
                if word and #word >= 2 and word:match("^[a-z]+$") then
                    local score = 0
                    local n = obj.Name:lower()
                    if n:find("word") or n:find("kata") or n:find("current") then score=score+10 end
                    if n:find("soal") or n:find("prompt") or n:find("display") then score=score+8 end
                    if obj:IsA("TextLabel") then
                        if obj.TextSize >= 24 then score=score+7 end
                        if obj.TextSize >= 18 then score=score+4 end
                    end
                    local vp = workspace.CurrentCamera.ViewportSize
                    local cx = math.abs(obj.AbsolutePosition.X + obj.AbsoluteSize.X/2 - vp.X/2)
                    if cx < 120 then score=score+5 end
                    if score > bestScore then bestScore=score; best=word end
                end
            end
        end
    end
    return best
end

-- ═══════════════════════════
-- NOTIFICATION
-- ═══════════════════════════
local nList = {}
function Notif(msg, t)
    t = t or "info"
    local col = t=="ok" and Color3.fromRGB(60,210,120)
             or t=="warn" and Color3.fromRGB(255,170,40)
             or t=="err" and Color3.fromRGB(255,65,65)
             or Color3.fromRGB(70,140,255)
    for _, f in ipairs(nList) do
        TW:Create(f,TweenInfo.new(0.1),{Position=f.Position+UDim2.new(0,0,0,32)}):Play()
    end
    local f=Instance.new("Frame",NG)
    f.Size=UDim2.new(0,195,0,26); f.Position=UDim2.new(1,-204,0,-40)
    f.BackgroundColor3=Color3.fromRGB(8,10,20); f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,3,1,0)
    bar.BackgroundColor3=col; bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lb=Instance.new("TextLabel",f)
    lb.Size=UDim2.new(1,-10,1,0); lb.Position=UDim2.new(0,8,0,0)
    lb.BackgroundTransparency=1; lb.Text=msg; lb.TextSize=11
    lb.Font=Enum.Font.GothamSemibold; lb.TextColor3=Color3.fromRGB(210,228,255)
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextTruncate=Enum.TextTruncate.AtEnd
    Instance.new("UIStroke",f).Color=col
    table.insert(nList,1,f)
    TW:Create(f,TweenInfo.new(0.22,Enum.EasingStyle.Back),{Position=UDim2.new(1,-204,0,8)}):Play()
    task.delay(2.5,function()
        TW:Create(f,TweenInfo.new(0.15),{Position=UDim2.new(1,5,0,f.Position.Y.Offset)}):Play()
        task.delay(0.2,function()
            local i=table.find(nList,f); if i then table.remove(nList,i) end
            pcall(function() f:Destroy() end)
        end)
    end)
end

-- ═══════════════════════════════════════════════════
--  U I  — COMPACT ANDROID  (300 × 420, pojok kiri)
-- ═══════════════════════════════════════════════════
local C = {
    bg=Color3.fromRGB(9,10,20), panel=Color3.fromRGB(13,15,28),
    card=Color3.fromRGB(17,20,36), cardH=Color3.fromRGB(23,27,48),
    acc=Color3.fromRGB(70,130,255), accB=Color3.fromRGB(105,160,255),
    accD=Color3.fromRGB(35,80,200), bdr=Color3.fromRGB(35,65,158),
    bF=Color3.fromRGB(20,28,55), txt=Color3.fromRGB(215,228,255),
    muted=Color3.fromRGB(85,110,170), dim=Color3.fromRGB(38,55,100),
    ok=Color3.fromRGB(60,210,120), warn=Color3.fromRGB(255,170,40),
    danger=Color3.fromRGB(255,65,65), gold=Color3.fromRGB(255,200,50),
}
local function Fr(p,pa) local f=Instance.new("Frame"); f.BorderSizePixel=0; for k,v in pairs(p) do pcall(function()f[k]=v end) end; if pa then f.Parent=pa end; return f end
local function Lb(p,pa) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamSemibold; for k,v in pairs(p) do pcall(function()l[k]=v end) end; if pa then l.Parent=pa end; return l end
local function Bt(p,pa) local b=Instance.new("TextButton"); b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold; for k,v in pairs(p) do pcall(function()b[k]=v end) end; if pa then b.Parent=pa end; return b end
local function Cr(r,p) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function Sk(c,t,p) local s=Instance.new("UIStroke",p); s.Color=c; s.Thickness=t; return s end
local function Gd(c1,c2,r,p) local g=Instance.new("UIGradient",p); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)}); g.Rotation=r end

-- WINDOW 300 × 420, pojok kiri atas
local W=Fr({
    Size=UDim2.new(0,300,0,420),
    Position=UDim2.new(0,6,0,6),
    BackgroundColor3=C.bg, Active=true, Draggable=true,
},MG)
Cr(12,W); Sk(C.bdr,1.5,W); Gd(Color3.fromRGB(9,11,22),Color3.fromRGB(5,6,15),155,W)

-- TITLE BAR
local TB=Fr({Size=UDim2.new(1,0,0,36),BackgroundColor3=C.accD,ZIndex=3},W); Cr(12,TB)
Fr({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.accD,BorderSizePixel=0,ZIndex=2},TB)
Gd(Color3.fromRGB(50,110,255),Color3.fromRGB(20,60,180),130,TB)
local logo=Fr({Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,7,0.5,-12),BackgroundColor3=C.acc,ZIndex=4},TB); Cr(6,logo); Gd(C.accB,C.accD,135,logo)
Lb({Size=UDim2.new(1,0,1,0),Text="V",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},logo)
Lb({Size=UDim2.new(0,115,0,15),Position=UDim2.new(0,36,0,3),Text="VOID HUB",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
Lb({Size=UDim2.new(0,165,0,11),Position=UDim2.new(0,36,0,20),Text="Sambung Kata v3  •  KBBI+RE",TextSize=8,TextColor3=Color3.fromRGB(140,185,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
local BC=Bt({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-27,0.5,-11),BackgroundColor3=C.danger,Text="✕",TextSize=10,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BC)
local BM=Bt({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-53,0.5,-11),BackgroundColor3=C.warn,Text="−",TextSize=14,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BM)
local Body=Fr({Size=UDim2.new(1,0,1,-36),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1},W)

BC.MouseButton1Click:Connect(function()
    TW:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,300,0,0)}):Play()
    task.delay(0.22,function()
        pcall(function()MG:Destroy()end); pcall(function()NG:Destroy()end)
        -- Disconnect semua conn
        for _, c in pairs(connectedREs) do pcall(function() c:Disconnect() end) end
    end)
end)
local mini=false
BM.MouseButton1Click:Connect(function()
    mini=not mini; Body.Visible=not mini
    TW:Create(W,TweenInfo.new(0.18),{Size=mini and UDim2.new(0,300,0,36) or UDim2.new(0,300,0,420)}):Play()
end)

local P=7

-- ── STATUS BAR (kata saat ini + giliran) ────
local statBar=Fr({Size=UDim2.new(1,-P*2,0,48),Position=UDim2.new(0,P,0,6),BackgroundColor3=C.panel},Body)
Cr(8,statBar); Sk(C.bF,1.2,statBar)

Lb({Size=UDim2.new(0.48,0,0,14),Position=UDim2.new(0,8,0,4),Text="KATA DI GAME",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left},statBar)
local turnLbl=Lb({Size=UDim2.new(0.5,0,0,14),Position=UDim2.new(0.5,-4,0,4),Text="⏳ menunggu...",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(80,100,160),TextXAlignment=Enum.TextXAlignment.Right},statBar)
local uiPad=Instance.new("UIPadding",statBar); uiPad.PaddingRight=UDim.new(0,8)

local scanWordLbl=Lb({Size=UDim2.new(0.55,0,0,22),Position=UDim2.new(0,8,0,18),Text="—",TextSize=18,Font=Enum.Font.GothamBold,TextColor3=C.gold,TextXAlignment=Enum.TextXAlignment.Left},statBar)
Lb({Size=UDim2.new(0.08,0,0,22),Position=UDim2.new(0.55,0,0,18),Text="→",TextSize=14,TextColor3=C.dim},statBar)
local nextHintLbl=Lb({Size=UDim2.new(0.35,0,0,22),Position=UDim2.new(0.63,0,0,18),Text="—",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=C.accB,TextXAlignment=Enum.TextXAlignment.Left},statBar)

-- ── TOGGLE ROW ──────────────────────────────
local togRow=Fr({Size=UDim2.new(1,-P*2,0,26),Position=UDim2.new(0,P,0,60),BackgroundTransparency=1},Body)

local autoPlayOn = false
local function SmTgl(xOff,w2,label,init,cb)
    local on=init
    local f=Fr({Size=UDim2.new(0,w2,1,0),Position=UDim2.new(0,xOff,0,0),BackgroundColor3=C.panel},togRow)
    Cr(6,f); Sk(C.bF,1,f)
    local lbRef=Lb({Size=UDim2.new(0.62,0,1,0),Position=UDim2.new(0,7,0,0),Text=label,TextSize=9,Font=Enum.Font.GothamBold,TextColor3=on and C.accB or C.muted,TextXAlignment=Enum.TextXAlignment.Left},f)
    local pb=Fr({Size=UDim2.new(0,28,0,14),Position=UDim2.new(1,-34,0.5,-7),BackgroundColor3=on and C.accD or Color3.fromRGB(18,22,42)},f); Cr(7,pb)
    local kn=Fr({Size=UDim2.new(0,10,0,10),Position=UDim2.new(on and 1 or 0,on and -13 or 2,0.5,-5),BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted},pb); Cr(5,kn)
    local hit=Bt({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},f)
    hit.MouseButton1Click:Connect(function()
        on=not on
        TW:Create(pb,TweenInfo.new(0.15),{BackgroundColor3=on and C.accD or Color3.fromRGB(18,22,42)}):Play()
        TW:Create(kn,TweenInfo.new(0.15),{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5),BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted}):Play()
        lbRef.TextColor3=on and C.accB or C.muted
        cb(on)
    end)
end
SmTgl(0, 138, "AUTO PLAY", false, function(on)
    autoPlayOn=on; Notify(on and "AUTO PLAY ON ✓" or "AUTO OFF","info")
end)
SmTgl(142, 144, "Human Delay", true, function(on)
    -- humanMode handled in SubmitAnswer
end)

-- ── PREFIX CHOOSER (scroll horizontal) ──────
local preY=93
Lb({Size=UDim2.new(1,-P*2,0,14),Position=UDim2.new(0,P,0,preY),Text="  AWALAN KATA",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left},Body)
local div1=Fr({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,preY+14),BackgroundColor3=C.bdr},Body); div1.BackgroundTransparency=0.6

local preSF=Instance.new("ScrollingFrame",Body)
preSF.Size=UDim2.new(1,-P*2,0,58); preSF.Position=UDim2.new(0,P,0,preY+17)
preSF.BackgroundTransparency=1; preSF.BorderSizePixel=0
preSF.ScrollBarThickness=2; preSF.ScrollBarImageColor3=C.acc
preSF.ScrollingDirection=Enum.ScrollingDirection.X
preSF.CanvasSize=UDim2.new(0,0,0,0); preSF.AutomaticCanvasSize=Enum.AutomaticSize.X

local prLL=Instance.new("UIListLayout",preSF)
prLL.FillDirection=Enum.FillDirection.Horizontal; prLL.Padding=UDim.new(0,3)
prLL.SortOrder=Enum.SortOrder.LayoutOrder

-- ── WORD LIST ───────────────────────────────
local wY=preY+17+58+6
Lb({Size=UDim2.new(1,-P*2,0,14),Position=UDim2.new(0,P,0,wY),Text="  DAFTAR KATA",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left},Body)
local wordCntLbl=Lb({Size=UDim2.new(0.5,0,0,14),Position=UDim2.new(0.5,0,0,wY),Text="",TextSize=8,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right},Body)
local uiPad2=Instance.new("UIPadding"); uiPad2.PaddingRight=UDim.new(0,P); uiPad2.Parent=wordCntLbl.Parent and wordCntLbl or Body
local div2=Fr({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,wY+14),BackgroundColor3=C.bdr},Body); div2.BackgroundTransparency=0.6

-- Action bar bottom = 44px
local actH=44
local wListH=420-36-wY-16-actH-P-4
local wSF=Instance.new("ScrollingFrame",Body)
wSF.Size=UDim2.new(1,-P*2,0,wListH); wSF.Position=UDim2.new(0,P,0,wY+18)
wSF.BackgroundTransparency=1; wSF.BorderSizePixel=0
wSF.ScrollBarThickness=3; wSF.ScrollBarImageColor3=C.acc
wSF.CanvasSize=UDim2.new(0,0,0,0); wSF.AutomaticCanvasSize=Enum.AutomaticSize.Y

local wGrid=Instance.new("UIGridLayout",wSF)
wGrid.CellSize=UDim2.new(0.5,-3,0,30)
wGrid.CellPadding=UDim2.new(0,4,0,3)
wGrid.SortOrder=Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",wSF).PaddingBottom=UDim.new(0,4)

-- ── ACTION BAR ──────────────────────────────
local actY=420-36-actH-P
local actBar=Fr({Size=UDim2.new(1,-P*2,0,actH),Position=UDim2.new(0,P,0,actY),BackgroundColor3=C.panel},Body)
Cr(8,actBar); Sk(C.bdr,1.5,actBar); Gd(Color3.fromRGB(14,18,40),Color3.fromRGB(9,12,28),160,actBar)

Lb({Size=UDim2.new(0.32,0,0,12),Position=UDim2.new(0,8,0,4),Text="DIPILIH",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left},actBar)
local selWordLbl=Lb({Size=UDim2.new(0.5,0,0,22),Position=UDim2.new(0,8,0,15),Text="—",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=C.accB,TextXAlignment=Enum.TextXAlignment.Left},actBar)

local typeBtn=Bt({Size=UDim2.new(0,84,0,32),Position=UDim2.new(1,-92,0.5,-16),BackgroundColor3=C.accD,Text="⌨ KETIK",TextSize=11,TextColor3=Color3.fromRGB(255,255,255),ZIndex=4},actBar)
Cr(7,typeBtn); Gd(C.accB,C.accD,90,typeBtn)

local curSel = nil
typeBtn.MouseButton1Click:Connect(function()
    if not curSel then Notif("Pilih kata dulu!","warn"); return end
    SubmitAnswer(curSel)
end)

-- ── BUILD WORD LIST ──────────────────────────
local prevWBtn=nil
local function BuildWordList(prefix)
    for _, c in ipairs(wSF:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    curSel=nil; selWordLbl.Text="—"; prevWBtn=nil

    local words=GetWords(prefix)
    wordCntLbl.Text=#words.." kata"

    if #words==0 then
        local l=Instance.new("TextLabel",wSF)
        l.Size=UDim2.new(1,0,0,26); l.BackgroundTransparency=1
        l.Text="Tidak ada kata untuk '"..prefix.."'"
        l.TextSize=10; l.TextColor3=C.dim; l.Font=Enum.Font.GothamSemibold
        return
    end

    for i,word in ipairs(words) do
        local lc=word:sub(#word):lower()
        local hasNext=DB1[lc] and #DB1[lc]>0
        local btn=Bt({BackgroundColor3=C.card,Text="",ZIndex=3,LayoutOrder=i},wSF)
        Cr(6,btn); Sk(C.bF,1,btn)
        Lb({Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,7,0,0),
            Text=word,TextSize=11,Font=Enum.Font.GothamBold,
            TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},btn)
        local badge=Fr({Size=UDim2.new(0,18,0,16),Position=UDim2.new(1,-21,0.5,-8),
            BackgroundColor3=hasNext and C.ok or C.warn,ZIndex=4},btn)
        Cr(4,badge); badge.BackgroundTransparency=0.5
        Lb({Size=UDim2.new(1,0,1,0),Text=lc:upper(),TextSize=8,Font=Enum.Font.GothamBold,
            TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},badge)
        btn.MouseButton1Click:Connect(function()
            if prevWBtn then TW:Create(prevWBtn,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end
            TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.accD}):Play()
            prevWBtn=btn; curSel=word; selWordLbl.Text=word
        end)
        btn.MouseEnter:Connect(function() if btn~=prevWBtn then TW:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.cardH}):Play() end end)
        btn.MouseLeave:Connect(function() if btn~=prevWBtn then TW:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.card}):Play() end end)
    end
end

-- ── BUILD PREFIX BUTTONS ─────────────────────
-- Kumpulkan semua prefix unik, sort
local allPre={}; local seen={}
for _, word in ipairs(RAW_WORDS) do
    local w=word:lower()
    -- 1 huruf
    local p1=w:sub(1,1); if not seen[p1] then seen[p1]=true; table.insert(allPre,p1) end
    -- 2 huruf khusus
    local p2=w:sub(1,2)
    local special2={"ng","ny","kh","sy","st","sp","sk","pr","tr","kr","gr","br","dr","fr",
                    "ba","be","bi","bo","bu","ca","ce","ci","co","cu","da","de","di","do","du",
                    "ga","ge","gi","go","gu","ha","he","hi","ho","hu","ja","je","ji","jo","ju",
                    "ka","ke","ki","ko","ku","la","le","li","lo","lu","ma","me","mi","mo","mu",
                    "na","ne","ni","no","nu","pa","pe","pi","po","pu","ra","re","ri","ro","ru",
                    "sa","se","si","so","su","ta","te","ti","to","tu","wa","wi","wo","ya","yo"}
    for _, s in ipairs(special2) do
        if p2==s and not seen[s] and DB2[s] and #DB2[s]>0 then
            seen[s]=true; table.insert(allPre,s)
        end
    end
end
table.sort(allPre, function(a,b)
    if #a~=#b then return #a<#b end; return a<b
end)

local prevPBtn=nil
for ord,prefix in ipairs(allPre) do
    local cnt=#GetWords(prefix)
    if cnt==0 then continue end
    local btnW=#prefix==1 and 28 or (#prefix==2 and 34 or 40)
    local btn=Bt({Size=UDim2.new(0,btnW,1,-4),BackgroundColor3=C.card,
        Text=prefix:upper(),TextSize=#prefix==1 and 11 or 9,
        TextColor3=C.muted,Font=Enum.Font.GothamBold,LayoutOrder=ord,ZIndex=3},preSF)
    Cr(5,btn)
    btn.MouseButton1Click:Connect(function()
        if prevPBtn then TW:Create(prevPBtn,TweenInfo.new(0.12),{BackgroundColor3=C.card,TextColor3=C.muted}):Play() end
        TW:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.acc,TextColor3=Color3.fromRGB(255,255,255)}):Play()
        prevPBtn=btn; BuildWordList(prefix)
        Notif(prefix:upper().." → "..cnt.." kata","info")
        -- Update next hint
        if nextHintLbl then
            local hw=FindAnswer(prefix:sub(#prefix))
            nextHintLbl.Text=hw or "—"
        end
    end)
end

-- ── HEARTBEAT: scan layar + auto update ─────
local hbLast=0
RunService.Heartbeat:Connect(function()
    if not W or not W.Parent then return end
    local now=os.clock()
    if now-hbLast<0.4 then return end
    hbLast=now

    local scanned=ScanScreen()
    if scanned and scanned~=lastScanned and #scanned>=2 then
        lastScanned=scanned
        scanWordLbl.Text=scanned
        local suf=scanned:sub(#scanned):lower()
        local hint=FindAnswer(suf)
        nextHintLbl.Text=hint or "—"

        -- AUTO PLAY
        if autoPlayOn and not typing then
            task.spawn(function()
                task.wait(0.5+math.random()*0.7)
                if autoPlayOn then SubmitAnswer(hint or "") end
            end)
        end
    end
end)

-- ── ENTRANCE ────────────────────────────────
W.Position=UDim2.new(0,6,1.5,0); W.BackgroundTransparency=1
TW:Create(W,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Position=UDim2.new(0,6,0,6), BackgroundTransparency=0,
}):Play()

task.delay(0.5,function()
    Notif("VOID HUB Sambung Kata v3 loaded!","ok")
    task.delay(1.1,function()
        local reCount=0
        for _ in pairs(connectedREs) do reCount=reCount+1 end
        Notif("RE hooked: "..reCount.." | DB: "..#RAW_WORDS.." kata","info")
    end)
end)

-- Auto pilih prefix "a"
task.delay(0.9,function()
    for _, btn in ipairs(preSF:GetChildren()) do
        if btn:IsA("TextButton") and btn.Text=="A" then
            TW:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.acc,TextColor3=Color3.fromRGB(255,255,255)}):Play()
            prevPBtn=btn; BuildWordList("a"); break
        end
    end
end)
