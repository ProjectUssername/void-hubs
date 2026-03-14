--[[
    VOID HUB | Sambung Kata
    Riset: GameController di workspace, detect giliran dari UI,
    submit via TextBox + Enter, kata dari TextLabel besar tengah layar.
    Anti-lag: 1 timer loop saja, tidak ada Heartbeat berulang.
]]

-- ────────────────────────────────────────────────────
-- SERVICES
-- ────────────────────────────────────────────────────
local Players    = game:GetService("Players")
local TweenSvc   = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- ────────────────────────────────────────────────────
-- GUI SETUP
-- ────────────────────────────────────────────────────
local function mkGui(name, z)
    local sg = Instance.new("ScreenGui")
    sg.Name = name; sg.ResetOnSpawn = false
    sg.DisplayOrder = z; sg.IgnoreGuiInset = true
    for _, f in ipairs({function() return game:GetService("CoreGui") end, function() return pg end}) do
        pcall(function() local o = f():FindFirstChild(name); if o then o:Destroy() end end)
    end
    if syn and syn.protect_gui then
        pcall(function() syn.protect_gui(sg) end)
        sg.Parent = game.CoreGui
    elseif gethui then
        sg.Parent = gethui()
    elseif not pcall(function() sg.Parent = game:GetService("CoreGui") end) then
        sg.Parent = pg
    end
    return sg
end

local GUI  = mkGui("VoidSK", 150)
local NGUI = mkGui("VoidSKN", 999)

-- ────────────────────────────────────────────────────
-- KOSAKATA KBBI  (~5000 kata paling umum)
-- Diindex per huruf pertama → lookup O(1)
-- ────────────────────────────────────────────────────
local DICT = {} -- DICT["a"] = {"abad","abadi",...}

do
    local raw = {
        -- A
        "abad","abadi","abah","abai","abang","abdi","abjad","abstrak","abu","acak",
        "acara","aceh","acuan","acuh","acung","ada","adab","adat","adegan","adil",
        "aduh","afiat","agak","agama","agih","agung","ahad","ahli","aib","air",
        "ajar","ajak","ajal","akan","akal","akad","akhir","akhlak","akrab","aksi",
        "aktif","akur","alam","alami","alas","alat","album","alias","alih","alim",
        "alir","alis","alit","alun","alur","aman","amat","ambil","ambang","amis",
        "ampas","ampuh","anak","aneh","angka","angkasa","angsa","angin","anjing",
        "antara","apung","arah","arang","arus","asah","asam","asin","asli","asuh",
        "atap","atur","awak","awam","awas","awet","ayah","ayam","ayat","azas",
        "azab","azan","azim","ajaran","akademi","aktivitas","akibat","amanah",
        "amanat","ambisi","amalan","analisa","angkat","antar","antri","aparat",
        "asing","aspirasi","asuransi","atlet","awal","ayunan","azimut",
        -- B
        "baca","bagian","bagus","bahasa","bahaya","bahu","baik","baja","bajak",
        "baju","bakti","balap","balas","balik","balon","bambu","barang","baris",
        "baru","basah","batas","batik","batok","baur","bayam","bayar","bebas",
        "bebek","bedah","bekal","bekas","belah","belas","beli","benar","benci",
        "benih","benua","beras","berat","berani","bersih","besok","betah","betul",
        "biaya","bibir","bimbang","bijak","bikin","bilas","bilang","bintang",
        "biru","bisik","bising","bocor","bola","bongkar","bohong","boleh","boros",
        "botak","buat","buah","bubuk","bubur","budak","budaya","bujuk","buku",
        "bulat","bulu","bulan","bumbu","bungkus","bunyi","buang","buruh","buruk",
        "buru","busuk","butuh","buyar","badai","bagai","bakso","bangga","bangkit",
        "bangsa","banjir","bantu","banyak","bapak","basmi","batasan","belajar",
        "berlari","bertanya","berwarna","blunder","bocoran","bodoh","boyot",
        "brilian","bukti","bungkam","bupati","bunga","bunda","bursa","buka",
        "buat","bilangan","berhasil","berkembang","bermain","bernama","berubah",
        -- C
        "cabang","cabut","cagar","cahaya","calon","campur","canggih","cantik",
        "capai","capek","cara","cakar","cakap","canda","cat","celah","cemas",
        "cepat","cerah","cerdas","cerdik","ceria","cemburu","cemar","cergas",
        "cermin","cerita","cicak","cicil","cikal","cinta","ciprat","cipta",
        "colek","comot","contoh","copot","coreng","cubit","cucuk","cukai","cuci",
        "cukup","cukur","culik","cumbu","cumi","cuaca","cuma","curang","curai",
        "curiga","curus","cuti","cendera","cengang","coblos","coret","cowok",
        "curhat","cakrawala","candaan","catatan","cekungan","cerewet","ceroboh",
        "ceplas","cerbung","cegah","celaka","cela","cemerlang","cenela",
        -- D
        "daftar","dalam","damai","dampak","dandang","danau","dapur","darah",
        "darat","darma","datang","dayak","dayung","debu","dedak","dekat","demam",
        "dendam","dengar","depan","deras","desa","dewan","dewasa","diam","didik",
        "dingin","dini","diri","dobrak","domba","dorong","dosa","drama","duit",
        "dulur","dusun","durian","dukung","dunia","duka","duri","dusta","dialog",
        "dinas","dilema","dinamis","disiplin","dukungan","darurat","derajat",
        "dermaga","desain","digital","dimensi","dominan","doktrin","donasi",
        "durasi","daulat","dayat","debat","dedikasi","dekat","demikian","deras",
        "desa","destinasi","detik","dewa","dewi","diam","diaspora","dibuka",
        -- E
        "edar","edukasi","efek","egois","ejaan","ejek","ekor","eksis","ekskul",
        "ekstra","ekspor","ekspres","eksplor","elastis","elak","elang","elok",
        "elus","embun","emak","emas","empang","empat","empuk","encik","endap",
        "energi","enggan","enjin","enak","era","erat","etika","etnis","evolusi",
        "esai","esok","empedal","ensiklopedia","entah","epos","erosi","erupsi",
        "ekuitas","ekonomi","ekologi","eksekusi","ekuivalen","eksplorasi",
        -- F
        "fadil","faedah","fajar","fakir","fakta","falak","famili","fana",
        "fardhu","fasad","fasih","fatwa","fasilitas","favorit","fenomena",
        "fikir","fikiran","fiksi","filsafat","final","fitnah","firasat",
        "fisika","fisik","fitrah","fleksibel","fobia","fondasi","fokus",
        "format","formula","forum","fosil","frasa","frontal","frustrasi",
        "fungsi","furnitur","faktor","faktur","falsafah","fana","fanatis",
        "fardu","fasilitasi","fatamorgana","filosofi","formalitas","frekuensi",
        -- G
        "gagah","gagal","galak","galau","galon","galur","gambar","ganas",
        "ganda","ganjil","garang","garuk","gasak","gatal","gaung","gayung",
        "gaib","gerak","gelak","gelas","gelombang","gempa","gendang","gertak",
        "gigih","gigit","gilap","gilas","girang","global","golek","golok",
        "goreng","gosip","goresan","goyang","gratis","gugur","gulung","gumam",
        "guntur","guna","gurat","gusar","guyur","guru","gembira","gemuk",
        "getah","gigi","galian","gangguan","gerangan","gundukan","gundul",
        "guratan","gadungan","gabungan","gagasan","galaksi","gambaran","ganjaran",
        "garuda","gawat","gedung","gelap","gemilang","gencatan","gerilya",
        -- H
        "hadap","hadiah","hafal","halal","halus","hambat","hampa","hancur",
        "hangat","hadir","hakim","haram","harmoni","harap","harga","hari",
        "harta","hasrat","hati","hawa","hebat","heboh","hemat","heran","hikayat",
        "hikmah","hilang","hilir","hina","hidup","hitam","hijau","hormati",
        "hormat","hubung","hulur","hujan","huruf","hutan","humanis","humor",
        "holistik","harapan","hartawan","hasutan","hentakan","hambatan",
        "halaman","hadangan","handal","hukum","hubungan","honorer","historis",
        -- I
        "ibu","ijazah","ikatan","ikat","ikhlas","ikhtiar","iklim","ikrar","ikut",
        "iman","imbal","imbas","imbuh","imam","impas","impor","impian","inap",
        "indah","ingin","ingat","ingkar","injak","insaf","inspirasi","intai",
        "inti","iringan","iringi","isap","islah","isyarat","istri","istimewa",
        "ilmu","inovasi","insan","investasi","isolasi","izin","identitas",
        "ideologi","imajinasi","implementasi","inisiatif","inklusif","institusi",
        "integrasi","intensi","interaksi","interpretasi","industri","informasi",
        "intelijen","internasional","isu","itikad","imbalan","impak","imperialis",
        -- J
        "jabatan","jadwal","jahit","jagoan","jaga","jago","jahat","jahil",
        "jaket","jalur","jamuan","janda","jangka","jangkau","jarong","jasad",
        "jasa","jatah","jalan","janji","jauh","jawab","jatuh","jelas","jeli",
        "jelita","jelma","jemput","jemur","jenaka","jenuh","jerami","jernih",
        "jijik","jinak","jinjit","jiplak","jiwa","joget","jorok","juara","jual",
        "juang","judul","jujur","junjung","jurang","jurnal","jurus","jadikan",
        "jalanan","jaminan","jangkauan","jasawan","jembatan","jenazah","jendela",
        "jenis","jenjang","jepret","jeratan","jumlah","jumpa","justru","jauhari",
        -- K
        "kaki","kalimat","kampung","kandang","kantuk","kapal","kapan","karang",
        "karena","karir","karung","karya","kasih","kasur","kata","kabur","kaget",
        "kagum","kasar","kawasan","kawan","kebun","kecil","kejar","kekal",
        "keliru","kembar","kendali","kerja","keras","kepala","kiri","kota",
        "kumpul","kisah","kocak","kolong","kompak","konsep","kuasa","kubur",
        "kuda","kuliah","kurang","kursi","kusut","kuning","kunci","kita","kali",
        "kaya","kayu","kemarahan","kebaikan","kehidupan","kemajuan","kenikmatan",
        "kepercayaan","kunyit","kupas","kurus","kutuk","kabupaten","kalangan",
        "kapasitas","karakteristik","kawanan","keadilan","keberhasilan",
        "kebijakan","kecemasan","kedudukan","kehilangan","kekayaan","kekuatan",
        "kelancaran","kelemahan","kemauan","kemiskinan","kesadaran","kesehatan",
        "kesempatan","kesenangan","ketidakadilan","kewajiban","keyakinan",
        "korupsi","kreativitas","kritikan","khasiat","khawatir","khayal",
        "khazanah","khalayak","khalifah","kharisma","khidmat","khilaf","khitan",
        "khotbah","khutbah","khusus","khusyuk","khas",
        -- L
        "labuh","ladang","lahir","lajur","lakon","lalai","larang","laris",
        "lasak","layang","layak","lazim","lebah","lebih","lebur","legam","leka",
        "lelah","lemah","lempar","lengan","lesu","lewat","libur","liar","lidah",
        "lincah","lingkar","lingkungan","lipas","lipat","lirih","listrik",
        "lolos","loncat","lorong","loteng","lubang","luhur","lulus","lumpur",
        "lumut","luncur","lutut","lucu","luka","lunas","luruh","lupa","lurus",
        "lama","lapar","laut","lari","loyal","layan","lihat","lambai","lambat",
        "lampau","lancar","landai","langkah","langsung","laporan","larut",
        "latihan","lawan","lebaran","lembaga","lembar","lempengan","lenyap",
        "lepas","lingkup","liputan","logika","luapan","lugas","lembut",
        -- M
        "mabuk","macan","macet","madani","magis","mahal","mahir","mainan",
        "maju","makhluk","makna","malah","malang","manis","manfaat","masalah",
        "masih","masuk","matang","makan","malam","malas","malu","mana","mandi",
        "marah","mata","mati","mau","meja","merah","mikir","mimpi","minta",
        "muda","mulai","murah","murni","musuh","mewah","milik","mimbar","mudah",
        "mulia","mundur","murung","musim","mampu","mantap","masyarakat",
        "meraih","merawat","merasa","meski","menang","mencari","mendapat",
        "mengerti","menjaga","menyayangi","madrasah","mahasiswa","makanan",
        "mandiri","mangsa","manusia","mengakui","mengelola","menguasai",
        "mengubah","menjalani","merancang","mewujudkan","migrasi","modernisasi",
        "motivasi","mufakat","musyawarah","manifestasi","manajemen",
        -- N
        "nada","nafas","nafkah","nahas","naik","nakal","nalar","naluri","nama",
        "nampak","nanti","napas","narasi","nasihat","nazar","negara","negeri",
        "nekat","nelayan","nenek","niaga","nifas","nikah","nikmat","niscaya",
        "nista","ngarai","norma","nisbah","notasi","nujum","nurani","nusantara",
        "nyanyi","nyali","nyala","nyaman","nyamuk","nyaris","nyata","nyawa",
        "nyeri","ngebut","ngerti","ngeluh","ngobrol","ngomong","ngopi","ngotot",
        "ngumpul","ngejar","ngemil","ngambil","ngantar","ngatur","ngajar",
        "ngasih","ngecat","ngeles","ngelirik","ngerem","ngeselin","ngetik",
        "ngewarnai","ngiris","ngoreng","ngoceh","ngintip","ngilang","ngitung",
        "nominal","normatif","nostalgia","notulen","nuzul","nafsu",
        -- O
        "obat","objek","obrolan","oceh","oksigen","olahraga","olah","omong",
        "ombak","ondeh","ongkos","opah","opini","optimis","orbit","ordal",
        "orasi","orde","organ","organisasi","orang","orientasi","orisinal",
        "otoritas","otonomi","otomatis","otak","otot","oleh","operasi","oval",
        "oknum","olimpiade","omongan","onderdil","open","opname","oportunis",
        -- P
        "pagi","paham","pahala","pakai","paksa","pandai","panjang","papan",
        "pasang","panas","pangkat","pasti","patuh","pecah","peduli","pekat",
        "peka","percaya","pergi","perlu","pesan","petang","piawai","pilihan",
        "pikir","pintar","pindah","pohon","polos","pondok","positif","puas",
        "pujian","pulang","pulih","punah","pupuk","purba","pusaka","penting",
        "penuh","perang","perahu","perintah","pribadi","prinsip","prioritas",
        "produk","profesi","program","proyek","proses","publik","pinjam",
        "pisah","pokok","potong","prihatin","paduan","pelajaran","pelayanan",
        "pemaknaan","pemikiran","pembangunan","pemberdayaan","pemerintahan",
        "penilaian","permasalahan","pertumbuhan","perusahaan","petualangan",
        "pilar","pintasan","platformer","pluralis","politis","populis","praktis",
        "pragmatis","prakarsa","prolog","properti","proposal","proteksi",
        "provokasi","prestasi","prima","produktif","progres","pemuda",
        -- R
        "raga","ragam","rakyat","ramah","ranah","rancak","randai","rapi",
        "rapuh","rasul","raut","rahayu","rahasia","rajin","rakus","ramalan",
        "rampas","randa","rangkul","rantai","rantau","ratap","rawat","rehat",
        "remaja","rencana","rendam","renggang","repot","resah","rindu","ritual",
        "riwayat","rombak","rompi","rontal","rontok","rohani","ruang","runding",
        "runtuh","runyam","rupiah","rugi","rumit","runcing","runtun","rupawan",
        "rusuh","ruwet","rasa","ramai","rapih","rapat","raih","redup","rela",
        "rendah","rezeki","riang","ringan","risau","rukun","rumbai","rusak",
        "ramadhan","rangkaian","ranting","realisasi","rekayasa","relasi",
        "reputasi","resolusi","revolusi","rahasiakan","rajawali","rakitan",
        -- S
        "sabda","sahaja","sahut","saing","salam","salah","santai","santun",
        "saran","sarjana","sasaran","satuan","sabar","sakit","sama","sayang",
        "selalu","semua","senang","serius","setia","siap","simpan","sinar",
        "singa","sopan","sukses","sunyi","syukur","segar","sehat","semangat",
        "sempurna","sentra","sepadu","sepakat","serasi","sering","siaga",
        "sigap","sikap","silap","simpul","sinergi","singkat","siswa","situasi",
        "skema","solusi","songket","sumber","sungguh","supaya","sulit","sulur",
        "sumbu","sumpah","surga","suruh","susah","syariah","solidaritas",
        "semesta","sabun","sahabat","sahih","salak","salut","sampah","sandal",
        "sangat","sangkut","santet","sarana","sarung","saksama","sadar",
        "samudra","sanggup","sebab","seluruh","senantiasa","seolah","seperti",
        "setidaknya","sinyal","sistem","sosialisasi","strategi","struktur",
        "stabil","standar","statis","stres","syahdu","syahid","syahadat",
        "syahwat","syaitan","syair","syarat","syariah","syariat","syirik",
        "syukuran","syok","saksama","sambung","sambutan","sumber","sungguh",
        "sukarela","sukacita","sulitnya","sulit",
        -- T
        "tabah","tabu","tahan","tajam","tapa","taruh","tatap","tawar",
        "tabiat","takluk","tali","tamak","tandas","tangguh","tanpa","tahu",
        "takut","tamat","tanda","tegar","teliti","tenang","terus","tiba",
        "tiga","tiket","tindak","tinggal","tujuan","tulus","tebal","teduh",
        "tegak","teguh","tekad","tekun","teladan","tempat","tentu","tepat",
        "terbang","terima","terlalu","tetap","tinggi","titik","tugas","tuntas",
        "turut","tutur","terbuka","termaju","terpadu","terpercaya","timbul",
        "tingkah","toleran","transparan","tumbuh","tunai","turun","tuntut",
        "tutup","tapak","tarikan","tatanan","tegalan","telaga","telapak",
        "tangan","tahapan","tanda","tangkas","tanggap","tanggung","tawaran",
        "teknologi","teladan","tercapai","terjamin","terpilih","tertib",
        "terukur","tindakan","tradisi","transfer","terlaksana","terselesai",
        -- U
        "ubah","udara","ukiran","ukur","ujar","ujian","ukhuwah","ulet",
        "ulang","ulam","ulas","ulat","ulos","umat","umpama","undur","unggas",
        "ungkap","unik","universal","unjuk","unsur","untung","upah","upaya",
        "urai","urgen","usaha","usik","usul","utama","utara","utuh","utas",
        "utang","ukuran","ulakan","ulangan","ulasan","umum","unggul",
        -- V
        "vaksin","valid","variasi","vendor","verbal","verifikasi","versi",
        "vertikal","veteran","veto","vibrasi","viral","visi","vitalitas",
        "virus","visioner","vital","vokal","vokasi","volunter","volume",
        -- W
        "wadah","wafat","wahana","wahyu","wakaf","wakil","walimah","walid",
        "walau","wangi","wanita","warga","warisan","warni","wartawan","wasit",
        "waspada","wasiat","watak","wawasan","wewenang","wibawa","wirausaha",
        "wisata","wong","wujud","wujudkan","wajar","waktu","wajah","warna",
        "warung","walimatulnikah","wedang","wirawan","warga","warisan",
        -- Y
        "yakini","yakin","yakni","yatim","yoga","yuran","yunior","yudha",
        "yuridis","yaitu","yamani","yaman","yayasan","yudisial","yunani",
        -- Z
        "zakat","zalim","zaman","ziarah","zigzag","zodiak","zona","zuhud",
        "zuriat","zikir","zakar","zanah","zariah","zenith","zionis","zirah",
        "zonasi","zuhur",
    }
    -- Index
    for _, w in ipairs(raw) do
        w = w:lower()
        local k = w:sub(1,1)
        if not DICT[k] then DICT[k] = {} end
        table.insert(DICT[k], w)
    end
end

-- ────────────────────────────────────────────────────
-- CORE LOGIC
-- ────────────────────────────────────────────────────
local usedWords = {}

local function getList(ch)
    return DICT[ch:lower()] or {}
end

-- Pilih kata terbaik: belum dipakai, panjang 4-9, huruf akhir ada lanjutannya
local function pickBest(suffix)
    local ch = suffix:lower():sub(-1)
    local pool = DICT[ch] or {}
    if #pool == 0 then return nil end

    local valid = {}
    for _, w in ipairs(pool) do
        if not usedWords[w] then
            local last   = w:sub(-1)
            local bonus  = (DICT[last] and #DICT[last] > 3) and 3 or 0
            local lenBonus = (#w >= 4 and #w <= 9) and 2 or 0
            table.insert(valid, {w=w, s=bonus+lenBonus+math.random()})
        end
    end
    -- Reset jika semua habis
    if #valid == 0 then
        for _, w in ipairs(pool) do
            table.insert(valid, {w=w, s=math.random()})
        end
    end
    table.sort(valid, function(a,b) return a.s > b.s end)
    local pick = valid[math.random(1, math.min(8,#valid))].w
    usedWords[pick] = true
    return pick
end

-- ────────────────────────────────────────────────────
-- GAME INTERACTION
-- Berdasarkan riset: game memakai TextBox input + Enter
-- Kata aktif ada di TextLabel TextSize besar di layar tengah
-- Giliran dari highlight nama player atau UI "TurnIndicator"
-- ────────────────────────────────────────────────────
local autoMode   = false
local humanDelay = true
local isTyping   = false
local lastKata   = ""

-- Cari TextBox input game
local function findInputBox()
    local best, bsc = nil, -1
    for _, gui in ipairs(pg:GetChildren()) do
        if gui == GUI or gui == NGUI or not gui:IsA("ScreenGui") then continue end
        for _, o in ipairs(gui:GetDescendants()) do
            if o:IsA("TextBox") and o.Visible and o.Interactable ~= false then
                local n  = o.Name:lower()
                local sc = 0
                if n:find("input") or n:find("answer") or n:find("chat") or n:find("word") or n:find("type") or n:find("ketik") then sc = sc + 10 end
                if o.AbsoluteSize.X > 150 then sc = sc + 3 end
                if o.AbsoluteSize.X > 250 then sc = sc + 3 end
                if sc > bsc then bsc = sc; best = o end
            end
        end
    end
    -- fallback: TextBox terbesar
    if not best then
        local bsz = 0
        for _, gui in ipairs(pg:GetChildren()) do
            if gui == GUI or gui == NGUI or not gui:IsA("ScreenGui") then continue end
            for _, o in ipairs(gui:GetDescendants()) do
                if o:IsA("TextBox") and o.Visible then
                    local sz = o.AbsoluteSize.X
                    if sz > bsz then bsz = sz; best = o end
                end
            end
        end
    end
    return best
end

-- Submit kata ke game
local function submitKata(word)
    if not word or #word == 0 or isTyping then return end
    isTyping = true
    task.spawn(function()
        local box = findInputBox()
        if box then
            -- focus
            pcall(function() box:CaptureFocus() end)
            task.wait(0.06)
            pcall(function() box.Text = "" end)
            task.wait(0.04)
            -- type per char
            for i = 1, #word do
                pcall(function() box.Text = word:sub(1,i) end)
                if humanDelay then
                    task.wait(0.07 + math.random() * 0.11)
                else
                    task.wait(0.04)
                end
            end
            task.wait(0.08)
            pcall(function() box:ReleaseFocus(true) end)
            task.wait(0.05)
            -- Enter
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:KeyDown(Enum.KeyCode.Return)
                task.wait(0.04)
                vu:KeyUp(Enum.KeyCode.Return)
            end)
            -- callback UI
            if _G._sk_onsubmit then _G._sk_onsubmit(word) end
        else
            -- tidak ada TextBox → beritahu user
            if _G._sk_nobox then _G._sk_nobox() end
        end
        task.wait(0.3)
        isTyping = false
    end)
end

-- Deteksi kata aktif dari layar
-- Prioritas: TextLabel dengan TextSize besar, posisi tengah, bukan milik GUI kita
local function scanKata()
    local best, bsc = nil, -1
    local vp = workspace.CurrentCamera.ViewportSize
    for _, gui in ipairs(pg:GetChildren()) do
        if gui == GUI or gui == NGUI or not gui:IsA("ScreenGui") then continue end
        for _, o in ipairs(gui:GetDescendants()) do
            if not o:IsA("TextLabel") then continue end
            if not o.Visible then continue end
            local t = o.Text:lower():gsub("[^a-z]","")
            if #t < 2 or #t > 20 then continue end
            if not t:match("^[a-z]+$") then continue end
            local sc  = 0
            local nm  = o.Name:lower()
            -- nama object
            if nm:find("word") or nm:find("kata") or nm:find("current") or nm:find("soal") then sc = sc + 15 end
            if nm:find("prompt") or nm:find("display") or nm:find("center") then sc = sc + 10 end
            if nm:find("question") or nm:find("challenge") then sc = sc + 10 end
            -- ukuran font
            if o.TextSize >= 32 then sc = sc + 12 end
            if o.TextSize >= 24 then sc = sc + 8  end
            if o.TextSize >= 18 then sc = sc + 4  end
            -- posisi tengah layar (horizontal)
            local mid = o.AbsolutePosition.X + o.AbsoluteSize.X / 2
            local dx  = math.abs(mid - vp.X / 2)
            if dx < 60  then sc = sc + 10 end
            if dx < 120 then sc = sc + 6  end
            if dx < 200 then sc = sc + 3  end
            -- posisi vertikal: tidak terlalu atas, tidak terlalu bawah
            local vy = o.AbsolutePosition.Y / vp.Y
            if vy >= 0.2 and vy <= 0.7 then sc = sc + 4 end
            if sc > bsc then bsc = sc; best = t end
        end
    end
    return best
end

-- Deteksi giliran dari UI
-- Berdasarkan riset: nama player di-highlight / warna berubah
local function detectMyTurn()
    local myName = lp.Name:lower()
    for _, gui in ipairs(pg:GetChildren()) do
        if gui == GUI or gui == NGUI or not gui:IsA("ScreenGui") then continue end
        for _, o in ipairs(gui:GetDescendants()) do
            -- Cek TextLabel yang isinya nama kita
            if o:IsA("TextLabel") and o.Visible then
                local t = o.Text:lower()
                if t:find(myName) then
                    -- cek apakah ini turn indicator
                    local nm = o.Name:lower()
                    if nm:find("turn") or nm:find("giliran") or nm:find("current") or nm:find("active") or nm:find("player") then
                        return true
                    end
                    -- cek warna: teks kuning/hijau/putih cerah = aktif
                    local col = o.TextColor3
                    local brightness = col.R*0.299 + col.G*0.587 + col.B*0.114
                    if brightness > 0.75 then return true end
                end
            end
            -- Frame highlight (background menyala saat giliran kita)
            if o:IsA("Frame") and o.Visible then
                local nm = o.Name:lower()
                if nm:find("turn") or nm:find("giliran") or nm:find("highlight") then
                    -- cek ada teks nama kita di dalamnya
                    for _, child in ipairs(o:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text:lower():find(myName) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- ────────────────────────────────────────────────────
-- NOTIFICATION
-- ────────────────────────────────────────────────────
local _nstack = {}
local _nc = {
    ok   = Color3.fromRGB(50,215,110),
    info = Color3.fromRGB(60,135,255),
    warn = Color3.fromRGB(255,165,35),
    err  = Color3.fromRGB(255,65,65),
}
local function Notif(msg, kind)
    kind = kind or "info"
    local col = _nc[kind] or _nc.info
    for _, f in ipairs(_nstack) do
        TweenSvc:Create(f, TweenInfo.new(0.1), {Position=f.Position+UDim2.new(0,0,0,32)}):Play()
    end
    local f = Instance.new("Frame", NGUI)
    f.Size = UDim2.new(0,195,0,26); f.Position = UDim2.new(1,-204,0,-50)
    f.BackgroundColor3 = Color3.fromRGB(10,11,22); f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,7)
    local stripe = Instance.new("Frame",f); stripe.Size=UDim2.new(0,3,1,0)
    stripe.BackgroundColor3=col; stripe.BorderSizePixel=0
    Instance.new("UICorner",stripe).CornerRadius=UDim.new(0,3)
    local lb = Instance.new("TextLabel",f)
    lb.Size=UDim2.new(1,-10,1,0); lb.Position=UDim2.new(0,8,0,0)
    lb.BackgroundTransparency=1; lb.Text=msg; lb.TextSize=11
    lb.Font=Enum.Font.GothamSemibold; lb.TextColor3=Color3.fromRGB(215,228,255)
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextTruncate=Enum.TextTruncate.AtEnd
    local sk=Instance.new("UIStroke",f); sk.Color=col; sk.Thickness=1; sk.Transparency=0.55
    table.insert(_nstack, 1, f)
    TweenSvc:Create(f,TweenInfo.new(0.25,Enum.EasingStyle.Back),{Position=UDim2.new(1,-204,0,10)}):Play()
    task.delay(2.8, function()
        TweenSvc:Create(f,TweenInfo.new(0.16),{Position=UDim2.new(1,8,0,f.Position.Y.Offset)}):Play()
        task.delay(0.18, function()
            local i=table.find(_nstack,f); if i then table.remove(_nstack,i) end
            pcall(function() f:Destroy() end)
        end)
    end)
end

-- ────────────────────────────────────────────────────
-- MAIN SCAN LOOP
-- Satu loop saja, interval 0.5 detik — TIDAK LAG
-- ────────────────────────────────────────────────────
local scanInterval = 0.5
local lastScanTime = 0
local lastAutoTime = 0

RunService.Heartbeat:Connect(function()
    if not GUI or not GUI.Parent then return end
    local now = os.clock()
    if now - lastScanTime < scanInterval then return end
    lastScanTime = now

    -- 1. Scan kata aktif
    local kata = scanKata()
    if kata and kata ~= lastKata then
        lastKata = kata
        if _G._sk_onkata then _G._sk_onkata(kata) end
    end

    -- 2. Auto mode: cek giliran, jawab
    if autoMode and not isTyping and kata and #kata >= 2 then
        if now - lastAutoTime < 1.2 then return end -- throttle auto
        local myTurn = detectMyTurn()
        if myTurn then
            lastAutoTime = now
            local ans = pickBest(kata)
            if ans then
                local delay = 0.8 + (humanDelay and math.random()*0.6 or 0)
                task.delay(delay, function()
                    if autoMode then submitKata(ans) end
                end)
            end
        end
    end
end)

-- ────────────────────────────────────────────────────
-- UI  ── 290 × 450, pojok kiri, tidak ganggu tengah
-- ────────────────────────────────────────────────────
local C = {
    bg    = Color3.fromRGB(9,10,19),
    bar   = Color3.fromRGB(13,15,27),
    card  = Color3.fromRGB(17,20,34),
    cardS = Color3.fromRGB(22,26,44),
    acc   = Color3.fromRGB(60,125,255),
    accB  = Color3.fromRGB(95,158,255),
    accD  = Color3.fromRGB(30,76,198),
    bdr   = Color3.fromRGB(30,60,152),
    bF    = Color3.fromRGB(20,27,52),
    txt   = Color3.fromRGB(218,228,255),
    mu    = Color3.fromRGB(80,108,168),
    dim   = Color3.fromRGB(36,52,96),
    ok    = Color3.fromRGB(50,215,110),
    warn  = Color3.fromRGB(255,165,35),
    red   = Color3.fromRGB(255,62,62),
    gold  = Color3.fromRGB(255,205,45),
    pill  = Color3.fromRGB(18,22,40),
}
-- shortcuts
local function F(p,pa)  local f=Instance.new("Frame");         f.BorderSizePixel=0; for k,v in pairs(p) do pcall(function()f[k]=v end) end; if pa then f.Parent=pa end; return f end
local function L(p,pa)  local l=Instance.new("TextLabel");    l.BackgroundTransparency=1; l.Font=Enum.Font.GothamSemibold; for k,v in pairs(p) do pcall(function()l[k]=v end) end; if pa then l.Parent=pa end; return l end
local function B(p,pa)  local b=Instance.new("TextButton");   b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold;    for k,v in pairs(p) do pcall(function()b[k]=v end) end; if pa then b.Parent=pa end; return b end
local function R(r,p)   Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function SK(c,t,p) local s=Instance.new("UIStroke",p); s.Color=c; s.Thickness=t; return s end
local function GD(a,b,r,p) local g=Instance.new("UIGradient",p); g.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,a),ColorSequenceKeypoint.new(1,b)}; g.Rotation=r end
local tw = function(o,pr,t,st,dr)
    TweenSvc:Create(o,TweenInfo.new(t,st or Enum.EasingStyle.Quad,dr or Enum.EasingDirection.Out),pr):Play()
end

local WW, WH = 290, 450

-- WINDOW
local WIN = F({Size=UDim2.new(0,WW,0,WH), Position=UDim2.new(0,6,0,6),
               BackgroundColor3=C.bg, Active=true, Draggable=true}, GUI)
R(12,WIN); SK(C.bdr,1.5,WIN); GD(Color3.fromRGB(9,12,22),Color3.fromRGB(5,6,14),155,WIN)

-- TITLE BAR
local TB = F({Size=UDim2.new(1,0,0,36), BackgroundColor3=C.accD, ZIndex=3}, WIN); R(12,TB)
F({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.accD,BorderSizePixel=0,ZIndex=2},TB)
GD(Color3.fromRGB(48,108,255),Color3.fromRGB(20,58,176),128,TB)

local logoBox = F({Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,7,0.5,-12),BackgroundColor3=C.acc,ZIndex=4},TB)
R(6,logoBox); GD(C.accB,C.accD,135,logoBox)
L({Size=UDim2.new(1,0,1,0),Text="V",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},logoBox)

L({Size=UDim2.new(0,112,0,14),Position=UDim2.new(0,36,0,4),
   Text="VOID HUB",TextSize=13,Font=Enum.Font.GothamBold,
   TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
L({Size=UDim2.new(0,165,0,11),Position=UDim2.new(0,36,0,21),
   Text="Sambung Kata  •  KBBI",TextSize=8,
   TextColor3=Color3.fromRGB(128,178,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)

local btnX = B({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-28,0.5,-11),
                BackgroundColor3=C.red,Text="✕",TextSize=10,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); R(5,btnX)
local btnM = B({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-54,0.5,-11),
                BackgroundColor3=C.warn,Text="−",TextSize=14,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); R(5,btnM)

local BODY = F({Size=UDim2.new(1,0,1,-36),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1},WIN)

btnX.MouseButton1Click:Connect(function()
    tw(WIN,{Size=UDim2.new(0,WW,0,0)},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
    task.delay(0.22,function()
        pcall(function()GUI:Destroy()end); pcall(function()NGUI:Destroy()end)
    end)
end)
local mini = false
btnM.MouseButton1Click:Connect(function()
    mini = not mini; BODY.Visible = not mini
    tw(WIN,{Size=mini and UDim2.new(0,WW,0,36) or UDim2.new(0,WW,0,WH)},0.18)
end)

local P = 7  -- padding

-- ── STATUS BAR ─────────────────────────────────────────
local stH = 46
local stBar = F({Size=UDim2.new(1,-P*2,0,stH),Position=UDim2.new(0,P,0,6),BackgroundColor3=C.bar},BODY)
R(8,stBar); SK(C.bF,1.2,stBar)

L({Size=UDim2.new(0.5,0,0,13),Position=UDim2.new(0,9,0,4),
   Text="KATA DI GAME",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.mu,
   TextXAlignment=Enum.TextXAlignment.Left},stBar)

local turnLbl = L({Size=UDim2.new(0.48,0,0,13),Position=UDim2.new(0.5,0,0,4),
                   Text="⏳ menunggu...",TextSize=8,Font=Enum.Font.GothamBold,
                   TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right},stBar)
Instance.new("UIPadding",turnLbl).PaddingRight=UDim.new(0,8)

local kataLbl = L({Size=UDim2.new(0.55,0,0,24),Position=UDim2.new(0,9,0,18),
                   Text="—",TextSize=21,Font=Enum.Font.GothamBold,
                   TextColor3=C.gold,TextXAlignment=Enum.TextXAlignment.Left},stBar)
L({Size=UDim2.new(0.08,0,0,24),Position=UDim2.new(0.55,0,0,18),
   Text="→",TextSize=14,TextColor3=C.dim},stBar)
local hintLbl = L({Size=UDim2.new(0.36,0,0,24),Position=UDim2.new(0.63,0,0,18),
                   Text="—",TextSize=13,Font=Enum.Font.GothamBold,
                   TextColor3=C.accB,TextXAlignment=Enum.TextXAlignment.Left},stBar)

-- ── TOGGLE ROW ─────────────────────────────────────────
local togY = 6 + stH + 5
local togRow = F({Size=UDim2.new(1,-P*2,0,26),Position=UDim2.new(0,P,0,togY),BackgroundTransparency=1},BODY)

local function mkTgl(xOff, ww, label, init, cb)
    local on = init
    local cont = F({Size=UDim2.new(0,ww,1,0),Position=UDim2.new(0,xOff,0,0),BackgroundColor3=C.bar},togRow)
    R(6,cont); SK(C.bF,1,cont)
    local lr = L({Size=UDim2.new(0.64,0,1,0),Position=UDim2.new(0,7,0,0),
                  Text=label,TextSize=9,Font=Enum.Font.GothamBold,
                  TextColor3=on and C.accB or C.mu,TextXAlignment=Enum.TextXAlignment.Left},cont)
    local pill = F({Size=UDim2.new(0,28,0,14),Position=UDim2.new(1,-34,0.5,-7),
                    BackgroundColor3=on and C.accD or C.pill},cont); R(7,pill)
    local knob = F({Size=UDim2.new(0,10,0,10),
                    Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5),
                    BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.mu},pill); R(5,knob)
    local hit = B({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},cont)
    hit.MouseButton1Click:Connect(function()
        on = not on
        tw(pill,{BackgroundColor3=on and C.accD or C.pill},0.15)
        tw(knob,{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5),
                 BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.mu},0.15)
        lr.TextColor3 = on and C.accB or C.mu
        cb(on)
    end)
end

mkTgl(0,   136, "AUTO PLAY", false, function(on)
    autoMode = on
    turnLbl.Text = on and "🤖 auto aktif" or "⏳ menunggu..."
    tw(turnLbl,{TextColor3=on and C.ok or C.dim},0.2)
    Notif(on and "AUTO PLAY ON ✓" or "AUTO PLAY OFF", on and "ok" or "warn")
end)
mkTgl(140, 140, "Human Delay", true, function(on)
    humanDelay = on
end)

-- ── HURUF GRID (scroll horizontal) ──────────────────────
local alpY = togY + 26 + 6
L({Size=UDim2.new(1,-P*2,0,13),Position=UDim2.new(0,P,0,alpY),
   Text="  PILIH AWALAN HURUF",TextSize=8,Font=Enum.Font.GothamBold,
   TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left},BODY)
F({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,alpY+13),BackgroundColor3=C.bdr},BODY).BackgroundTransparency=0.6

local aSF = Instance.new("ScrollingFrame",BODY)
aSF.Size=UDim2.new(1,-P*2,0,46); aSF.Position=UDim2.new(0,P,0,alpY+16)
aSF.BackgroundTransparency=1; aSF.BorderSizePixel=0
aSF.ScrollBarThickness=2; aSF.ScrollBarImageColor3=C.acc
aSF.ScrollingDirection=Enum.ScrollingDirection.X
aSF.CanvasSize=UDim2.new(0,0,0,0); aSF.AutomaticCanvasSize=Enum.AutomaticSize.X
local aLL=Instance.new("UIListLayout",aSF); aLL.FillDirection=Enum.FillDirection.Horizontal
aLL.Padding=UDim.new(0,3); aLL.SortOrder=Enum.SortOrder.LayoutOrder

-- ── SEARCH BOX ──────────────────────────────────────────
local srchY = alpY + 16 + 46 + 4
local srchF = F({Size=UDim2.new(1,-P*2,0,28),Position=UDim2.new(0,P,0,srchY),BackgroundColor3=C.bar},BODY)
R(7,srchF); SK(C.bF,1,srchF)
L({Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,7,0,0),Text="🔍",TextSize=12,TextColor3=C.mu},srchF)
local srchTB = Instance.new("TextBox",srchF)
srchTB.Size=UDim2.new(1,-32,1,0); srchTB.Position=UDim2.new(0,26,0,0)
srchTB.BackgroundTransparency=1; srchTB.ClearTextOnFocus=false; srchTB.Text=""
srchTB.PlaceholderText="Filter kata..."; srchTB.Font=Enum.Font.GothamSemibold
srchTB.TextSize=11; srchTB.TextColor3=C.txt; srchTB.PlaceholderColor3=C.dim
srchTB.TextXAlignment=Enum.TextXAlignment.Left

-- ── WORD COUNT ──────────────────────────────────────────
local wcY = srchY + 28 + 3
local wcL = L({Size=UDim2.new(1,-P*2,0,13),Position=UDim2.new(0,P,0,wcY),
               Text="Pilih huruf untuk mulai",TextSize=8,Font=Enum.Font.GothamBold,
               TextColor3=C.mu,TextXAlignment=Enum.TextXAlignment.Left},BODY)
F({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,wcY+13),BackgroundColor3=C.bdr},BODY).BackgroundTransparency=0.6

-- ── WORD SCROLL ─────────────────────────────────────────
local actH = 42
local wSY  = wcY + 15
local wSH  = WH - 36 - wSY - actH - P - 4

local wSF = Instance.new("ScrollingFrame",BODY)
wSF.Size=UDim2.new(1,-P*2,0,wSH); wSF.Position=UDim2.new(0,P,0,wSY)
wSF.BackgroundTransparency=1; wSF.BorderSizePixel=0
wSF.ScrollBarThickness=3; wSF.ScrollBarImageColor3=C.acc
wSF.CanvasSize=UDim2.new(0,0,0,0); wSF.AutomaticCanvasSize=Enum.AutomaticSize.Y
local wGrid=Instance.new("UIGridLayout",wSF)
wGrid.CellSize=UDim2.new(0.5,-3,0,30)
wGrid.CellPadding=UDim2.new(0,4,0,3)
wGrid.SortOrder=Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",wSF).PaddingBottom=UDim.new(0,4)

-- ── ACTION BAR ──────────────────────────────────────────
local aBarY = WH - 36 - actH - P
local aBar  = F({Size=UDim2.new(1,-P*2,0,actH),Position=UDim2.new(0,P,0,aBarY),BackgroundColor3=C.bar},BODY)
R(9,aBar); SK(C.bdr,1.5,aBar); GD(Color3.fromRGB(13,17,38),Color3.fromRGB(8,11,26),158,aBar)

L({Size=UDim2.new(0.3,0,0,12),Position=UDim2.new(0,9,0,3),Text="DIPILIH",TextSize=8,
   Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left},aBar)
local selLbl = L({Size=UDim2.new(0.56,0,0,22),Position=UDim2.new(0,9,0,16),
                  Text="—",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=C.accB,
                  TextXAlignment=Enum.TextXAlignment.Left},aBar)
local sendBtn = B({Size=UDim2.new(0,80,0,30),Position=UDim2.new(1,-88,0.5,-15),
                   BackgroundColor3=C.accD,Text="⌨ KIRIM",TextSize=11,
                   TextColor3=Color3.fromRGB(255,255,255),ZIndex=4},aBar)
R(7,sendBtn); GD(C.accB,C.accD,90,sendBtn)
sendBtn.MouseEnter:Connect(function() tw(sendBtn,{BackgroundColor3=C.acc},0.1) end)
sendBtn.MouseLeave:Connect(function() tw(sendBtn,{BackgroundColor3=C.accD},0.1) end)

local curSel = nil
sendBtn.MouseButton1Click:Connect(function()
    if not curSel then Notif("Pilih kata dulu!","warn"); return end
    submitKata(curSel)
end)

-- ── WORD LIST BUILDER ────────────────────────────────────
local prevWBtn = nil

local function buildList(ch, filter)
    for _, c in ipairs(wSF:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    curSel = nil; selLbl.Text = "—"; prevWBtn = nil

    local all = getList(ch)
    local words = {}
    if filter and #filter > 0 then
        local fl = filter:lower()
        for _, w in ipairs(all) do
            if w:find(fl,1,true) then table.insert(words,w) end
        end
    else
        words = all
    end

    wcL.Text = #words.." kata  ('"..ch:upper().."')"
    if #words == 0 then
        L({Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,
           Text="Tidak ada kata",TextSize=10,TextColor3=C.dim,Font=Enum.Font.GothamSemibold},wSF)
        return
    end

    for i, word in ipairs(words) do
        local last    = word:sub(-1):lower()
        local hasNext = DICT[last] and #DICT[last] > 2
        local btn = B({BackgroundColor3=C.card,Text="",ZIndex=3,LayoutOrder=i},wSF)
        R(6,btn); SK(C.bF,1,btn)
        L({Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,8,0,0),
           Text=word,TextSize=11,Font=Enum.Font.GothamBold,
           TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},btn)
        local bdg = F({Size=UDim2.new(0,18,0,16),Position=UDim2.new(1,-21,0.5,-8),
                       BackgroundColor3=hasNext and C.ok or C.warn,ZIndex=4},btn)
        R(4,bdg); bdg.BackgroundTransparency=0.45
        L({Size=UDim2.new(1,0,1,0),Text=last:upper(),TextSize=8,Font=Enum.Font.GothamBold,
           TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},bdg)
        btn.MouseButton1Click:Connect(function()
            if prevWBtn then tw(prevWBtn,{BackgroundColor3=C.card},0.1) end
            tw(btn,{BackgroundColor3=C.accD},0.1); SK(C.acc,1.5,btn)
            prevWBtn=btn; curSel=word; selLbl.Text=word
        end)
        btn.MouseEnter:Connect(function() if btn~=prevWBtn then tw(btn,{BackgroundColor3=C.cardS},0.08) end end)
        btn.MouseLeave:Connect(function() if btn~=prevWBtn then tw(btn,{BackgroundColor3=C.card},0.08) end end)
    end
end

-- Search filter
local curAlpha = "a"
srchTB:GetPropertyChangedSignal("Text"):Connect(function()
    buildList(curAlpha, srchTB.Text)
end)

-- ── ALPHABET BUTTONS ────────────────────────────────────
local prevABtn = nil
local alphaBtns = {}

local function selectAlpha(ch, btnRef)
    if prevABtn then tw(prevABtn,{BackgroundColor3=C.card,TextColor3=C.mu},0.12) end
    tw(btnRef,{BackgroundColor3=C.acc,TextColor3=Color3.fromRGB(255,255,255)},0.12)
    prevABtn = btnRef; curAlpha = ch
    srchTB.Text = ""
    buildList(ch,"")
    -- preview hint
    local h = pickBest(ch)
    if h then hintLbl.Text = h else hintLbl.Text = "—" end
end

for i = 1, 26 do
    local ch  = string.char(96+i)
    local cnt = DICT[ch] and #DICT[ch] or 0
    local btn = B({Size=UDim2.new(0,30,1,-4),BackgroundColor3=C.card,
                   Text=ch:upper(),TextSize=11,
                   TextColor3=cnt>0 and C.mu or C.dim,
                   Font=Enum.Font.GothamBold,LayoutOrder=i,ZIndex=3},aSF)
    R(5,btn)
    alphaBtns[ch] = btn
    btn.MouseButton1Click:Connect(function() selectAlpha(ch,btn) end)
end

-- ── UI CALLBACKS dari SCAN LOOP ────────────────────────
_G._sk_onkata = function(kata)
    kataLbl.Text = kata
    -- hint
    local ans = pickBest(kata)
    hintLbl.Text = ans or "—"
    -- auto-select huruf terakhir di grid
    local last = kata:sub(-1):lower()
    if alphaBtns[last] then
        selectAlpha(last, alphaBtns[last])
    end
    -- update turn display
    if detectMyTurn() then
        turnLbl.Text = "✅ GILIRAN KAMU"
        tw(turnLbl,{TextColor3=C.ok},0.2)
    else
        turnLbl.Text = "⏳ giliran lawan"
        tw(turnLbl,{TextColor3=C.dim},0.2)
    end
end

_G._sk_onsubmit = function(word)
    Notif("✓ "..word, "ok")
    selLbl.Text = word
end

_G._sk_nobox = function()
    Notif("TextBox tidak ditemukan!", "err")
end

-- ── ENTRANCE ANIMATION ───────────────────────────────────
WIN.Position = UDim2.new(0,6,1.5,0); WIN.BackgroundTransparency = 1
tw(WIN,{Position=UDim2.new(0,6,0,6),BackgroundTransparency=0},0.44,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

task.delay(0.5, function()
    local total = 0
    for _, v in pairs(DICT) do total = total + #v end
    Notif("VOID HUB • Sambung Kata loaded!", "ok")
    task.delay(1.1, function()
        Notif("DB: "..total.." kata siap", "info")
    end)
    -- default A
    task.delay(0.7, function()
        if alphaBtns["a"] then selectAlpha("a",alphaBtns["a"]) end
    end)
end)
