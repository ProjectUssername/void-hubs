-- VOID HUB | Sambung Kata Edition
-- Database KBBI per huruf | Auto Type | Human-like delay
-- Pilih awalan huruf → pilih kata → ketik otomatis

-- ══════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════
local Players   = game:GetService("Players")
local UIS       = game:GetService("UserInputService")
local TW        = game:GetService("TweenService")
local RunService= game:GetService("RunService")
local VU        = game:GetService("VirtualUser")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════════════
-- SAFE GUI PARENT
-- ══════════════════════════════════════
local function MkGui(name, ord)
    local sg = Instance.new("ScreenGui")
    sg.Name = name
    sg.ResetOnSpawn = false
    sg.DisplayOrder = ord or 100
    sg.IgnoreGuiInset = true
    if syn and syn.protect_gui then
        syn.protect_gui(sg); sg.Parent = game.CoreGui
    elseif gethui then
        sg.Parent = gethui()
    else
        local ok = pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not ok then sg.Parent = pg end
    end
    return sg
end

for _, n in ipairs({"VoidSambungKata","VoidSKNotif"}) do
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild(n)
        if old then old:Destroy() end
    end)
    pcall(function()
        local old = pg:FindFirstChild(n)
        if old then old:Destroy() end
    end)
end

local MainGui = MkGui("VoidSambungKata", 100)
local NotiGui = MkGui("VoidSKNotif", 999)

-- ══════════════════════════════════════
-- DATABASE KATA KBBI PER HURUF
-- (300+ kata per huruf, dipilih yang umum & valid)
-- ══════════════════════════════════════
local KBBI = {
    a = {
        "alam","api","ada","air","anak","ayah","adik","abang","ambil","angkat",
        "angin","akar","atas","awas","akhir","awal","arif","azan","azab","akad",
        "ambu","alun","adab","abdi","abai","abang","abis","abot","abus","acar",
        "acuh","acak","acap","adat","adil","agak","agam","agen","agung","ahli",
        "ajak","ajal","ajar","ajuk","akan","akal","akar","aksi","aktif","aku",
        "alah","alam","alap","alias","alim","alir","alun","alur","amah","aman",
        "amat","ambil","amis","ampas","ampuh","anak","anam","aneh","angka","angsa",
        "aniaya","anjing","antara","apung","arah","arang","arus","asah","asam",
        "asin","asli","asuh","atap","atur","awam","awet","ayam","ayat","azas",
    },
    b = {
        "baca","bahu","baju","bali","bawa","besar","bisa","buat","buah","buku",
        "bulan","bumbu","bunyi","buruk","buru","basah","batas","bayar","bebas",
        "bekal","bekas","belah","belas","beli","benih","berat","berita","berkat",
        "bijak","bikin","bilas","bilang","bintang","bocah","bodoh","bohong","boleh",
        "boros","botak","bubur","bugis","bukan","bumi","bungkus","bunglon","buruh",
        "busuk","butuh","buyar","bahagia","baik","bakti","balap","balasan","balik",
        "balon","bambu","barang","baris","barua","baru","batik","batok","baur",
        "bayam","bazar","bebek","bedah","benar","benci","benua","beras","berbagi",
        "beradu","berani","berdiri","berguna","berhenti","berjalan","berkah","bersih",
        "bersatu","bertanya","besok","betah","betul","biaya","bibir","bimbang",
    },
    c = {
        "cari","cinta","cobak","cuci","cukup","curang","cepat","cerita","cermat",
        "cantik","capai","cakar","cakap","canda","cara","cat","cita","coba",
        "cocok","corak","cuaca","cuma","cabang","cabut","cagar","cahaya","calon",
        "campur","canggih","capek","celah","cemas","cepat","cerah","cermat","cerdas",
        "cerita","cicak","cikal","cinta","ciprat","cipta","colek","comot","contoh",
        "copot","coreng","cubit","cucuk","cukai","cukur","culik","cumbu","cumi",
        "cunang","cupak","curai","curiga","curus","cuti","cendekia","cerewet",
        "cerdik","cemerlang","ceria","cermat","cemburu","cemar","cendera","cengang",
    },
    d = {
        "dalam","damai","dapur","darah","darat","datang","daya","dekat","dengar",
        "desa","dewasa","diam","didik","dingin","diri","duduk","dunia","duka",
        "duri","dusta","dapat","dagang","dahan","dahulu","daun","dawai","dayung",
        "debu","dedak","dedikasi","dekat","demam","dendam","depan","deras","dewan",
        "dialog","digul","dinas","dini","dobrak","dogma","dolar","domba","dorong",
        "dosa","durian","dukung","duluan","duri","dusta","dukungan","dasar","dasarnya",
        "daftar","dakwah","dalang","damba","dampak","dandan","danau","darma","daya",
        "dayak","decak","degup","dekat","delapan","demikian","derma","desak","desah",
    },
    e = {
        "ekor","elok","emak","emas","empat","enak","encik","engkau","era","esok",
        "etika","enak","elang","empuk","encok","endap","enggan","erat","erat",
        "etes","edar","edukasi","efek","efisien","egois","elastis","elegance",
        "emosi","empati","energi","etika","evolusi","ekspor","ekskul","eksak",
        "ejaan","ejek","ekor","eksis","eksak","elak","elang","elus","embun",
        "emosi","empang","empuk","endap","enjin","epal","erat","erit","esai",
        "etnis","ewah","ekstra","ekspres","eksplor","elemen","edarkan","ejawantah",
    },
    f = {
        "faham","fakta","familia","fanatik","fatal","firasat","fokus","formal",
        "forum","fungsi","furnitur","fasad","fasilitas","favorit","fenomena",
        "fikir","fitnah","fondasi","formula","fosil","frustrasi","fabel","fadil",
        "fajar","fakir","falak","famili","fana","fardu","fasa","fasih","fatwa",
        "fesyen","fiksi","filantropi","filsafat","final","fisika","fisik","fitrah",
        "fleksibel","fobia","formal","format","frasa","friksi","frontal","fujur",
    },
    g = {
        "gagah","gaji","gampang","gerak","gigih","guna","guru","gembira","gelap",
        "gemuk","getah","gigi","girang","golok","goyang","gabung","gadis","gagal",
        "galak","galon","galur","ganas","ganjil","garang","garuk","gasak","gatal",
        "gaung","gayung","gelak","gelas","gelombang","gempa","gendang","gertak",
        "gigit","gilap","gilas","gimbap","golek","goresan","gosip","gugur","gulung",
        "gumam","guntur","gurat","gusar","guyur","gabah","gaib","galau","gambar",
        "ganda","getir","giat","gigih","global","godaan","goreng","gratis","gula",
    },
    h = {
        "hadir","halus","harga","hari","haus","hebat","hemat","hidup","hijau","hilang",
        "hormat","hujan","hutan","habis","hakim","harap","harta","hasrat","hati",
        "hawa","heboh","heran","hina","hitam","hubung","hulur","humban","huruf",
        "hadap","hadiah","hafal","halal","hambat","hampa","hancur","hangat","haram",
        "harap","harmoni","hasil","hasut","hemat","hening","hikmah","hokum","horor",
        "hukum","huruf","harapan","hargai","harmoni","hebat","hikayat","hilir",
        "hormati","hidayah","himbauan","hipokrit","holistik","humanis","humor",
    },
    i = {
        "ibu","ikan","ikut","ilmu","iman","impian","indah","ingin","ingat","juga",
        "isu","izin","ikhlas","iklim","ikrar","irama","istri","ikat","ijazah",
        "ikhtiar","imam","imbal","imbas","imbuh","impas","impor","inap","ingin",
        "injak","insaf","intai","inti","introspeksi","iringi","isap","isyarat",
        "ikhlas","ilahi","ilalang","ilusi","imajinasi","inovasi","insan","inspirasi",
        "integrasi","intensi","interaksi","investasi","iras","iringan","isolasi",
        "istimewa","itung","iya","ingkar","intan","isis","ikatan","ikat","iman",
    },
    j = {
        "jaga","jalan","janji","jauh","jawab","jelas","jujur","jumpa","jangan",
        "jatuh","jiwa","jual","juang","jagoan","jago","jahat","jahil","jaket",
        "jalur","jamur","janda","jantan","jarong","jasad","jasa","jatah","jemu",
        "jerih","jitu","jodoh","jorok","juara","jujur","junjung","jurang","jasa",
        "jabatan","jadwal","jahit","jalan","jamuan","jangka","jangkau","jatuh",
        "jelas","jelita","jelma","jemput","jemur","jenaka","jenuh","jerami","jernih",
        "jijik","jinak","jinjit","jiplak","joget","judul","jugal","jurnal","jurus",
    },
    k = {
        "kata","kerja","kuat","kuning","kunci","kita","kali","kaya","kayu","keras",
        "kepala","kiri","kota","kumpul","kasih","kabar","kaki","kali","kalau",
        "kalung","kamar","kamus","kantor","kapal","karya","kasur","ketika","kirim",
        "kolam","kurang","kursi","kusut","kabur","kaget","kagum","kasar","kawasan",
        "kawan","keadilan","kebun","kecil","kejar","kekal","keliru","kembar","kendali",
        "kesal","kisah","kocak","kolong","kompak","konsep","kuasa","kubur","kuda",
        "kuliah","kumpul","kundur","kunyit","kupas","kurban","kurus","kutuk","keras",
        "kemarahan","kebaikan","kehidupan","kemajuan","kenikmatan","kepercayaan",
    },
    l = {
        "lari","laut","lepas","lihat","lurus","lupa","lama","lapar","lembut","licin",
        "loyal","lucu","luka","lunas","luruh","labuh","ladang","lahir","lajur",
        "lakon","lalai","larang","laris","lasak","layang","lebah","lebih","legam",
        "leka","lengah","lengkap","lepak","lewat","liar","lincah","lingkar","lipas",
        "lipat","lirih","listrik","lolos","loncat","lorong","loteng","loyak","luban",
        "lubang","luhur","lulus","lumpur","lumut","luncur","lutut","layan","layak",
        "lazim","lebur","lelah","lemah","lempar","lengan","lesu","liar","libur",
        "lidah","lingkungan","liputan","logika","luapan","lugas","luhur","lurus",
    },
    m = {
        "maju","makan","malam","malas","malu","mana","mandi","marah","masuk","mata",
        "mati","mau","meja","merah","mikir","mimpi","minta","muda","mulai","murah",
        "murni","musuh","mahal","mahir","mainan","maju","makna","malah","malang",
        "manis","manfaat","masalah","masih","masuk","matang","mewah","milik","mimbar",
        "mudah","mulia","mundur","munur","murung","musim","mabuk","maju","makhluk",
        "malam","mampu","mantap","masyarakat","memacu","membantu","memberi","memimpin",
        "menang","mencari","mendapat","mengerti","menghormati","mengikuti","menjelaskan",
        "menjaga","menyayangi","meraih","merawat","merasa","meski","mewujudkan",
    },
    n = {
        "naik","nama","nada","nafas","nakal","nasib","niat","nilai","nikah","nikmat",
        "nyaman","nyata","nyanyi","nyawa","nabati","nafkah","nalar","nampak","nanti",
        "napas","narasi","nasihat","nazar","negara","nekat","nelayan","nenek","niaga",
        "nifas","nikmat","nimbus","nipis","nirom","nisbah","niscaya","nista","normal",
        "notasi","nujum","nyalang","nyali","nyaman","nyaman","nyanyian","nyaris",
        "naga","nagari","nahas","naikkan","naluri","nyata","nyeri","nyilu","nonton",
        "nurani","nusantara","nyanyi","nyata","nisbah","norma","nalar","nampak",
    },
    o = {
        "obat","olahraga","olah","orang","ombak","omong","opini","optimis","otak",
        "otot","oleh","operasi","orbital","ordal","orasi","obrolan","objek","odoh",
        "oksigen","organisasi","orientasi","orisinal","otoritas","otonomi","otomatis",
        "obrol","oceh","onak","ondeh","ongkos","opah","orang","orbit","orde",
        "organ","osis","oval","owah","obyek","omega","onset","ootd","opera",
    },
    p = {
        "pagi","paham","pandai","panjang","papan","pasang","peduli","perlu","pikir",
        "pintar","pohon","puasa","pulang","punya","putih","padu","pahala","pakai",
        "paksa","panas","pangkat","pasti","patuh","pecah","pejalan","pekat","peka",
        "percaya","pergi","pesan","petang","piawai","pilihan","polos","pondok",
        "positif","puas","pujian","pukulan","pulih","punah","pupuk","purba","pusaka",
        "pilih","pindah","pinggir","pingsan","pinjam","pisah","pitam","piutang",
        "pokok","polah","porak","potong","prihatin","pribadi","prinsip","prioritas",
        "produk","profesi","program","proyek","proses","publik","penuh","penting",
    },
    r = {
        "rasa","ramai","rapih","rapat","raih","rajin","ramah","randa","rangkul",
        "rantai","rapi","rasa","rawat","redup","rela","rendah","rezeki","riang",
        "ringan","risau","rohani","rukun","rumbai","rusak","ragu","rahayu","rahasia",
        "raih","rakus","ramai","ramalan","rampas","rancang","rancangan","randuk",
        "rangkai","rantau","rasa","ratap","rehat","remaja","rencana","rendam","rengan",
        "renggang","repot","resah","rindu","ritual","riwayat","rohaniah","rombak",
        "rompi","rondo","rontal","rontok","ruang","runding","runtuh","runyam","rupiah",
        "rugi","rumit","runcing","runtun","rupawan","rusuh","ruwet","raga","ragam",
    },
    s = {
        "sabar","sakit","sama","sayang","selalu","semua","senang","serius","setia",
        "siap","simpan","sinar","singa","sopan","sukses","sunyi","syukur","sabda",
        "sahaja","sahut","saing","salam","salah","santai","santun","saran","sarjana",
        "sasaran","satuan","segar","sehat","semangat","sempurna","sentra","sepadu",
        "sepakat","serasi","sering","siaga","sigap","sikap","silap","simpul","sinergi",
        "singkat","sinkron","siswa","situasi","skema","solusi","songket","sumber",
        "sungguh","supaya","sulit","sulur","sumbu","sumpah","sunyi","surga","suruh",
        "susah","susul","swakarsa","syariah","syarif","syukur","solidaritas","semesta",
    },
    t = {
        "tahu","takut","tamat","tanda","tegar","teliti","tenang","terus","tiba","tiga",
        "tiket","tindak","tinggal","tujuan","tulus","tabah","tabu","tahan","tajam",
        "tanda","tapa","taruh","tatap","tawar","tebal","teduh","tegak","teguh","tekad",
        "tekun","teladan","tempat","tentu","tepat","terbang","terima","terlalu","tetap",
        "tiba","tinggi","titik","tugas","tuntas","turut","tutur","tabiat","takluk",
        "tali","tamak","tandas","tangguh","tanpa","terbuka","terlindung","termaju",
        "terpadu","terpercaya","terselesai","terus","timbul","tingkah","toleran",
        "transparan","trampil","tujuan","tumbuh","tunai","turun","tuntut","tutup",
    },
    u = {
        "ubah","udara","uji","ukur","ulang","unik","untung","urang","usaha","utama",
        "ulur","umum","unggul","upaya","urai","urun","usul","utuh","ujar","ujian",
        "ukiran","ulasan","ulet","ulur","umur","ungkap","unjuk","unsur","unyuk",
        "upah","upama","urai","urgen","usik","utara","utuh","ukhuwah","umat",
        "umpama","unik","unitasi","universal","unsung","urus","usap","utamakan",
        "utas","uyup","ukuran","ulak","ulam","ulangan","ulangan","ulasan","ulet",
    },
    v = {
        "vaksin","valid","variasi","vital","vokal","volume","varian","visi","vulkan",
        "validasi","vegetasi","ventilasi","verifikasi","versi","veteran","vibran",
        "vitalitas","visualisasi","virus","visioner","virtuoso","victoria","vigor",
        "viral","vakum","vokasi","volunter","votasi","vegetal","velvet","vendor",
    },
    w = {
        "wajar","waktu","wajah","warna","warung","wasiat","waspada","wijak","wujud",
        "walau","wanita","warga","warisan","watak","wewenang","wijaksana","wirausaha",
        "wujudkan","wahyu","walid","waris","wartawan","wawasan","webinar","wijak",
        "wirasa","wisata","wiyata","warga","wartawan","wujud","wangi","wataknya",
        "wakaf","walimah","waspada","welas","wibawa","wirausaha","wisata","wong",
    },
    y = {
        "yakin","yang","yakni","yatim","yuran","yunior","yudisial","yuridis",
        "yakini","yahudi","yasmin","yantra","yatim","yelp","yoga","yoman","yonder",
        "yudha","yuran","yusuf","yaitu","yakni","yamani","yangon","yantra","yasmin",
    },
    z = {
        "zaman","zakat","zalim","zikir","zona","zorba","zuhud","zuriat","zodiak",
        "zakar","zaman","zanah","zariah","zatil","zauji","ziarah","zigzag","zinah",
        "zionis","zirah","zonasi","zorba","zuriat","zuhur","zuhal","zakat","zaman",
    },
}

-- ══════════════════════════════════════
-- STATE
-- ══════════════════════════════════════
local State = {
    activeLetter   = nil,   -- huruf yang dipilih
    filteredWords  = {},    -- kata yang muncul di list
    selectedWord   = nil,   -- kata yang dipilih user
    autoMode       = false, -- auto detect & type
    humanDelay     = true,  -- typing delay manusiawi
    searchText     = "",    -- filter pencarian
    minDelay       = 0.08,
    maxDelay       = 0.22,
    thinkDelay     = true,
    answerDelay    = 0.8,   -- jeda sebelum mulai ketik
}

-- ══════════════════════════════════════
-- UTILS
-- ══════════════════════════════════════

-- Cari TextBox input game
local function FindGameInput()
    for _, gui in ipairs(pg:GetChildren()) do
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextBox") then
                local n = obj.Name:lower()
                local p = obj.Parent and obj.Parent.Name:lower() or ""
                if n:find("input") or n:find("answer") or n:find("chat")
                or n:find("word") or n:find("kata") or n:find("teks")
                or p:find("input") or p:find("chat") or p:find("game") then
                    return obj
                end
            end
        end
    end
    -- fallback: TextBox terbesar yang visible
    local best, bestSize = nil, 0
    for _, gui in ipairs(pg:GetChildren()) do
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextBox") and obj.Visible then
                local sz = obj.AbsoluteSize.X * obj.AbsoluteSize.Y
                if sz > bestSize then bestSize=sz; best=obj end
            end
        end
    end
    return best
end

-- Detect kata saat ini dari game UI
local function DetectCurrentWord()
    for _, gui in ipairs(pg:GetChildren()) do
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                local t = obj.Text:lower()
                local n = obj.Name:lower()
                -- Cari label yang kemungkinan menampilkan kata saat ini
                if (n:find("current") or n:find("word") or n:find("kata")
                or n:find("soal") or n:find("prompt") or n:find("display"))
                and #t >= 2 and #t <= 20 then
                    -- Pastikan itu kata (hanya huruf)
                    if t:match("^[a-z]+$") then
                        return t
                    end
                end
            end
        end
    end
    return nil
end

-- Human-like typing
local function TypeWord(word)
    if not word or #word == 0 then return end

    -- Cari input box
    local inputBox = FindGameInput()
    if not inputBox then
        -- Fallback: VirtualUser keyboard
        inputBox = nil
    end

    -- Jeda "mikir" sebelum mulai ketik
    if State.thinkDelay then
        local think = State.answerDelay + math.random(0,5)*0.1
        task.wait(think)
    end

    if inputBox then
        -- Fokus ke TextBox
        pcall(function()
            inputBox:CaptureFocus()
            inputBox.Text = ""
        end)
        task.wait(0.1)

        -- Ketik per karakter dengan delay acak
        for i = 1, #word do
            local char = word:sub(i,i)
            pcall(function()
                inputBox.Text = word:sub(1,i)
            end)
            if State.humanDelay then
                local delay = State.minDelay + math.random() * (State.maxDelay - State.minDelay)
                task.wait(delay)
            else
                task.wait(0.05)
            end
        end

        -- Enter / submit
        task.wait(0.1)
        pcall(function() inputBox:ReleaseFocus(true) end)

        -- Simulasi Enter key
        pcall(function()
            VU:KeyDown(Enum.KeyCode.Return)
            task.wait(0.05)
            VU:KeyUp(Enum.KeyCode.Return)
        end)
    else
        -- Fallback: VirtualUser type
        pcall(function()
            if State.thinkDelay then task.wait(State.answerDelay) end
            for i = 1, #word do
                VU:KeyDown(Enum.KeyCode[word:sub(i,i):upper()] or Enum.KeyCode.Unknown)
                task.wait(0.05)
                VU:KeyUp(Enum.KeyCode[word:sub(i,i):upper()] or Enum.KeyCode.Unknown)
            end
        end)
    end
end

-- Filter kata berdasarkan awalan
local function FilterWords(letter, search)
    letter = letter:lower()
    search = search and search:lower() or ""
    local words = KBBI[letter] or {}
    if search == "" then
        return words
    end
    local filtered = {}
    for _, w in ipairs(words) do
        if w:lower():find(search, 1, true) then
            table.insert(filtered, w)
        end
    end
    return filtered
end

-- Cari kata terbaik dari huruf terakhir
local function BestWordForLetter(letter)
    letter = letter:lower()
    local words = KBBI[letter] or {}
    if #words == 0 then return nil end
    -- Pilih kata yang lebih panjang (lebih susah dilanjutkan lawan)
    local sorted = {}
    for _, w in ipairs(words) do table.insert(sorted, w) end
    table.sort(sorted, function(a,b) return #a > #b end)
    -- Pilih acak dari top 10 (agar tidak terlalu obvious)
    local pool = math.min(10, #sorted)
    return sorted[math.random(1, pool)]
end

-- ══════════════════════════════════════
-- NOTIFICATION
-- ══════════════════════════════════════
local nList = {}
local function Notify(msg, t)
    t = t or "info"
    local col = t=="ok" and Color3.fromRGB(0,200,110)
             or t=="warn" and Color3.fromRGB(255,160,0)
             or t=="err" and Color3.fromRGB(255,55,55)
             or Color3.fromRGB(0,130,255)
    for _, f in ipairs(nList) do
        TW:Create(f,TweenInfo.new(0.12),{Position=f.Position+UDim2.new(0,0,0,36)}):Play()
    end
    local f = Instance.new("Frame",NotiGui)
    f.Size = UDim2.new(0,210,0,28)
    f.Position = UDim2.new(1,-220,0,-40)
    f.BackgroundColor3 = Color3.fromRGB(8,10,20)
    f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",f); bar.Size=UDim2.new(0,3,1,0); bar.BackgroundColor3=col; bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lb=Instance.new("TextLabel",f)
    lb.Size=UDim2.new(1,-10,1,0); lb.Position=UDim2.new(0,8,0,0)
    lb.BackgroundTransparency=1; lb.Text=msg; lb.TextSize=11
    lb.Font=Enum.Font.GothamSemibold; lb.TextColor3=Color3.fromRGB(200,220,255)
    lb.TextXAlignment=Enum.TextXAlignment.Left; lb.TextTruncate=Enum.TextTruncate.AtEnd
    table.insert(nList,1,f)
    TW:Create(f,TweenInfo.new(0.25,Enum.EasingStyle.Back),{Position=UDim2.new(1,-220,0,8)}):Play()
    task.delay(2.5,function()
        TW:Create(f,TweenInfo.new(0.18),{Position=UDim2.new(1,10,0,f.Position.Y.Offset)}):Play()
        task.delay(0.2,function()
            local i=table.find(nList,f); if i then table.remove(nList,i) end
            pcall(function() f:Destroy() end)
        end)
    end)
end

-- ══════════════════════════════════════════════════════
--  U I   B U I L D E R   —   VOID HUB
-- ══════════════════════════════════════════════════════
local C = {
    bg     = Color3.fromRGB(8, 9, 18),
    panel  = Color3.fromRGB(12, 14, 26),
    card   = Color3.fromRGB(16, 19, 34),
    cardH  = Color3.fromRGB(20, 24, 44),
    acc    = Color3.fromRGB(80, 140, 255),
    accB   = Color3.fromRGB(110, 165, 255),
    accD   = Color3.fromRGB(40, 90, 200),
    border = Color3.fromRGB(40, 70, 160),
    bF     = Color3.fromRGB(20, 28, 55),
    txt    = Color3.fromRGB(215, 228, 255),
    muted  = Color3.fromRGB(90, 115, 175),
    dim    = Color3.fromRGB(40, 58, 105),
    ok     = Color3.fromRGB(60, 210, 120),
    warn   = Color3.fromRGB(255, 170, 40),
    danger = Color3.fromRGB(255, 65, 65),
    letter = Color3.fromRGB(120, 190, 255),
    sel    = Color3.fromRGB(0, 80, 200),
    selH   = Color3.fromRGB(30, 110, 240),
}

local function Fr(p,pa)
    local f=Instance.new("Frame"); f.BorderSizePixel=0
    for k,v in pairs(p) do pcall(function()f[k]=v end) end
    if pa then f.Parent=pa end; return f
end
local function Lb(p,pa)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamSemibold
    for k,v in pairs(p) do pcall(function()l[k]=v end) end
    if pa then l.Parent=pa end; return l
end
local function Bt(p,pa)
    local b=Instance.new("TextButton"); b.BorderSizePixel=0
    b.Font=Enum.Font.GothamBold
    for k,v in pairs(p) do pcall(function()b[k]=v end) end
    if pa then b.Parent=pa end; return b
end
local function Cr(r,p) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function Sk(c,t,p) local s=Instance.new("UIStroke",p); s.Color=c; s.Thickness=t; return s end
local function Gd(c1,c2,r,p)
    local g=Instance.new("UIGradient",p)
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)})
    g.Rotation=r
end

-- ── WINDOW ────────────────────────────────────
-- Lebih ramping: 340 × 500
local W = Fr({
    Size=UDim2.new(0,340,0,500),
    Position=UDim2.new(0.5,-170,0.5,-250),
    BackgroundColor3=C.bg,
    Active=true, Draggable=true,
}, MainGui)
Cr(14,W); Sk(C.border,1.5,W)
Gd(Color3.fromRGB(8,10,22),Color3.fromRGB(5,6,15),160,W)

-- ── TITLE BAR ─────────────────────────────────
local TB = Fr({Size=UDim2.new(1,0,0,44),BackgroundColor3=C.accD,ZIndex=3},W)
Cr(14,TB)
Fr({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.accD,BorderSizePixel=0,ZIndex=2},TB)
Gd(Color3.fromRGB(50,110,255),Color3.fromRGB(20,60,180),130,TB)

-- Logo
local logo=Fr({Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,8,0.5,-15),BackgroundColor3=C.acc,ZIndex=4},TB)
Cr(8,logo); Gd(C.accB,C.accD,135,logo)
Lb({Size=UDim2.new(1,0,1,0),Text="V",TextSize=17,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},logo)

Lb({Size=UDim2.new(0,130,0,20),Position=UDim2.new(0,44,0,4),Text="VOID HUB",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
Lb({Size=UDim2.new(0,190,0,13),Position=UDim2.new(0,44,0,25),Text="Sambung Kata  •  KBBI Database",TextSize=9,TextColor3=Color3.fromRGB(150,190,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)

local BC=Bt({Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-34,0.5,-13),BackgroundColor3=C.danger,Text="✕",TextSize=12,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(6,BC)
local BM=Bt({Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-64,0.5,-13),BackgroundColor3=C.warn,Text="−",TextSize=16,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(6,BM)

local Body=Fr({Size=UDim2.new(1,0,1,-44),Position=UDim2.new(0,0,0,44),BackgroundTransparency=1},W)

BC.MouseButton1Click:Connect(function()
    TW:Create(W,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,340,0,0)}):Play()
    task.delay(0.25,function()
        pcall(function() MainGui:Destroy() end)
        pcall(function() NotiGui:Destroy() end)
    end)
end)

local mini=false
BM.MouseButton1Click:Connect(function()
    mini=not mini; Body.Visible=not mini
    TW:Create(W,TweenInfo.new(0.2),{Size=mini and UDim2.new(0,340,0,44) or UDim2.new(0,340,0,500)}):Play()
end)

-- ══════════════════════════════════════════════
-- LAYOUT UTAMA (tidak pakai tab — satu halaman)
-- Body dibagi:
--   [Info Bar]      → kata saat ini + auto toggle
--   [Huruf A-Z]     → grid 26 tombol
--   [Search Bar]    → filter kata
--   [Word List]     → scroll kata hasil filter
--   [Bottom Bar]    → kata terpilih + tombol ketik
-- ══════════════════════════════════════════════

local pad = 10  -- padding kiri kanan

-- ── INFO BAR ──────────────────────────────────
local InfoBar = Fr({
    Size=UDim2.new(1,-pad*2,0,38),
    Position=UDim2.new(0,pad,0,8),
    BackgroundColor3=C.card,
}, Body)
Cr(8,InfoBar); Sk(C.bF,1,InfoBar)

-- Label kata saat ini
local curWordLbl = Lb({
    Size=UDim2.new(0.55,0,1,0), Position=UDim2.new(0,10,0,0),
    Text="Kata saat ini: —",
    TextSize=11, TextColor3=C.muted, TextXAlignment=Enum.TextXAlignment.Left,
}, InfoBar)

-- Auto Mode toggle
local autoLabel = Lb({
    Size=UDim2.new(0.22,0,1,0), Position=UDim2.new(0.55,0,0,0),
    Text="AUTO", TextSize=10, Font=Enum.Font.GothamBold,
    TextColor3=C.dim,
}, InfoBar)

local autoPill = Fr({
    Size=UDim2.new(0,42,0,20), Position=UDim2.new(1,-52,0.5,-10),
    BackgroundColor3=Color3.fromRGB(18,22,42),
}, InfoBar)
Cr(10,autoPill); Sk(C.bF,1,autoPill)
local autoKnob = Fr({
    Size=UDim2.new(0,14,0,14), Position=UDim2.new(0,3,0.5,-7),
    BackgroundColor3=C.muted,
}, autoPill)
Cr(7,autoKnob)

local autoHit = Bt({Size=UDim2.new(0,80,1,0),Position=UDim2.new(1,-88,0,0),BackgroundTransparency=1,Text="",ZIndex=5},InfoBar)
autoHit.MouseButton1Click:Connect(function()
    State.autoMode = not State.autoMode
    local on = State.autoMode
    TW:Create(autoPill,TweenInfo.new(0.18),{BackgroundColor3=on and C.accD or Color3.fromRGB(18,22,42)}):Play()
    TW:Create(autoKnob,TweenInfo.new(0.18),{
        Position=on and UDim2.new(0,25,0.5,-7) or UDim2.new(0,3,0.5,-7),
        BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted
    }):Play()
    TW:Create(autoLabel,TweenInfo.new(0.18),{TextColor3=on and C.accB or C.dim}):Play()
    Notify(on and "AUTO ON — mendeteksi kata" or "AUTO OFF","info")
end)

-- ── HURUF A-Z GRID ────────────────────────────
local letterSec = Lb({
    Size=UDim2.new(1,-pad*2,0,16),
    Position=UDim2.new(0,pad,0,54),
    Text="  PILIH AWALAN HURUF",
    TextSize=9, Font=Enum.Font.GothamBold, TextColor3=C.acc,
    TextXAlignment=Enum.TextXAlignment.Left,
}, Body)
local line1 = Fr({Size=UDim2.new(1,-pad*2,0,1),Position=UDim2.new(0,pad,0,70),BackgroundColor3=C.border},Body)
line1.BackgroundTransparency=0.6

local LetterGrid = Fr({
    Size=UDim2.new(1,-pad*2,0,78),
    Position=UDim2.new(0,pad,0,74),
    BackgroundTransparency=1,
}, Body)
local lgLayout = Instance.new("UIGridLayout",LetterGrid)
lgLayout.CellSize = UDim2.new(0,28,0,24)
lgLayout.CellPadding = UDim2.new(0,3,0,3)
lgLayout.SortOrder = Enum.SortOrder.LayoutOrder

local alphabet = "abcdefghijklmnopqrstuvwxyz"
local letterBtns = {}
local selectedLetterBtn = nil

-- Word list refs (diisi nanti)
local wordScrollFrame, wordListLayout, wordButtons

local function RefreshWordList(letter, search)
    -- Clear existing buttons
    if wordScrollFrame then
        for _, ch in ipairs(wordScrollFrame:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
    end
    if not letter then return end

    local words = FilterWords(letter, search)
    State.filteredWords = words

    if #words == 0 then
        local lbl = Lb({
            Size=UDim2.new(1,0,0,30),
            Text="Tidak ada kata ditemukan",
            TextSize=11, TextColor3=C.dim,
        }, wordScrollFrame)
        return
    end

    for i, word in ipairs(words) do
        local btn = Bt({
            Size=UDim2.new(1,-4,0,30),
            BackgroundColor3=C.card,
            Text="",
            ZIndex=3,
            LayoutOrder=i,
        }, wordScrollFrame)
        Cr(6,btn)
        local sk2 = Sk(C.bF,1,btn)

        -- Huruf terakhir (berguna untuk lanjut)
        local lastChar = word:sub(#word):upper()
        local lastCol = KBBI[word:sub(#word)] and C.ok or C.warn

        Lb({Size=UDim2.new(0.65,0,1,0),Position=UDim2.new(0,10,0,0),
            Text=word, TextSize=12, Font=Enum.Font.GothamBold,
            TextColor3=C.txt, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=4}, btn)

        -- Badge huruf terakhir
        local badge=Fr({Size=UDim2.new(0,22,0,20),Position=UDim2.new(1,-58,0.5,-10),BackgroundColor3=lastCol,ZIndex=4},btn)
        Cr(5,badge)
        badge.BackgroundTransparency=0.6
        Lb({Size=UDim2.new(1,0,1,0),Text=lastChar,TextSize=10,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},badge)

        -- Panjang kata
        Lb({Size=UDim2.new(0.25,0,1,0),Position=UDim2.new(0.72,0,0,0),
            Text=#word.." hrf", TextSize=9, TextColor3=C.dim, ZIndex=4}, btn)

        btn.MouseButton1Click:Connect(function()
            -- Update selected
            for _, b in ipairs(wordButtons or {}) do
                if b ~= btn then
                    pcall(function()
                        TW:Create(b,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play()
                        Sk(C.bF,1,b)
                    end)
                end
            end
            TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.sel}):Play()
            Sk(C.acc,1.5,btn)
            State.selectedWord = word
            -- Update bottom bar
            if selectedWordLbl then
                selectedWordLbl.Text = word
            end
            Notify("Pilih: "..word.." (akhiran: "..lastChar..")","ok")
        end)

        btn.MouseEnter:Connect(function()
            if State.selectedWord ~= word then
                TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.cardH}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if State.selectedWord ~= word then
                TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play()
            end
        end)

        table.insert(wordButtons or {}, btn)
    end

    -- Label jumlah
    if wordCountLbl then
        wordCountLbl.Text = #words.." kata (awalan "..letter:upper()..")"
    end
end

-- Buat tombol huruf
for i = 1, #alphabet do
    local ch = alphabet:sub(i,i)
    local count = KBBI[ch] and #KBBI[ch] or 0
    local btn = Bt({
        BackgroundColor3=C.card, Text=ch:upper(),
        TextSize=11, TextColor3=C.muted,
        Font=Enum.Font.GothamBold,
        LayoutOrder=i, ZIndex=3,
    }, LetterGrid)
    Cr(5,btn)
    Sk(C.bF,1,btn)

    -- Warna berdasarkan jumlah kata
    local dotCol = count >= 50 and C.ok or count >= 20 and C.warn or C.danger

    btn.MouseButton1Click:Connect(function()
        -- Deselect old
        if selectedLetterBtn and selectedLetterBtn ~= btn then
            TW:Create(selectedLetterBtn,TweenInfo.new(0.15),{
                BackgroundColor3=C.card, TextColor3=C.muted
            }):Play()
        end
        selectedLetterBtn = btn
        TW:Create(btn,TweenInfo.new(0.15),{
            BackgroundColor3=C.acc, TextColor3=Color3.fromRGB(255,255,255)
        }):Play()
        State.activeLetter = ch
        State.selectedWord = nil
        if searchBox then searchBox.Text="" end
        State.searchText = ""
        wordButtons = {}
        RefreshWordList(ch, "")
        if wordCountLbl then
            wordCountLbl.Text = (KBBI[ch] and #KBBI[ch] or 0).." kata (awalan "..ch:upper()..")"
        end
    end)
    letterBtns[ch] = btn
end

-- ── SEARCH BAR ────────────────────────────────
local searchY = 74 + 78 + 8

local searchSec = Lb({
    Size=UDim2.new(1,-pad*2,0,14),
    Position=UDim2.new(0,pad,0,searchY),
    Text="  CARI KATA",
    TextSize=9, Font=Enum.Font.GothamBold, TextColor3=C.acc,
    TextXAlignment=Enum.TextXAlignment.Left,
}, Body)
local line2 = Fr({Size=UDim2.new(1,-pad*2,0,1),Position=UDim2.new(0,pad,0,searchY+14),BackgroundColor3=C.border},Body)
line2.BackgroundTransparency=0.6

local searchFrame = Fr({
    Size=UDim2.new(1,-pad*2,0,30),
    Position=UDim2.new(0,pad,0,searchY+18),
    BackgroundColor3=C.card,
}, Body)
Cr(8,searchFrame); Sk(C.bF,1,searchFrame)

Lb({Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,8,0,0),Text="🔍",TextSize=12},searchFrame)

local searchBox = Instance.new("TextBox",searchFrame)
searchBox.Size = UDim2.new(1,-36,1,0)
searchBox.Position = UDim2.new(0,28,0,0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Filter kata..."
searchBox.Font = Enum.Font.GothamSemibold
searchBox.TextSize = 12
searchBox.TextColor3 = C.txt
searchBox.PlaceholderColor3 = C.dim
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    State.searchText = searchBox.Text
    wordButtons = {}
    if State.activeLetter then
        RefreshWordList(State.activeLetter, searchBox.Text)
    end
end)

-- ── WORD LIST ─────────────────────────────────
local listY = searchY + 18 + 30 + 6

local listHeader = Fr({
    Size=UDim2.new(1,-pad*2,0,20),
    Position=UDim2.new(0,pad,0,listY),
    BackgroundTransparency=1,
}, Body)
local wordCountLbl = Lb({
    Size=UDim2.new(1,0,1,0),
    Text="Pilih huruf untuk melihat kata",
    TextSize=9, Font=Enum.Font.GothamBold, TextColor3=C.muted,
    TextXAlignment=Enum.TextXAlignment.Left,
}, listHeader)

-- Scroll height: sisa dari listY+20 sampai 500-44-60 (bottom bar)
local scrollH = 500 - 44 - listY - 20 - 66
wordScrollFrame = Instance.new("ScrollingFrame",Body)
wordScrollFrame.Size = UDim2.new(1,-pad*2,0,scrollH)
wordScrollFrame.Position = UDim2.new(0,pad,0,listY+22)
wordScrollFrame.BackgroundTransparency=1; wordScrollFrame.BorderSizePixel=0
wordScrollFrame.ScrollBarThickness=3; wordScrollFrame.ScrollBarImageColor3=C.acc
wordScrollFrame.CanvasSize=UDim2.new(0,0,0,0); wordScrollFrame.AutomaticCanvasSize=Enum.AutomaticSize.Y

wordListLayout = Instance.new("UIListLayout",wordScrollFrame)
wordListLayout.Padding=UDim.new(0,3); wordListLayout.SortOrder=Enum.SortOrder.LayoutOrder
local wlPad=Instance.new("UIPadding",wordScrollFrame); wlPad.PaddingBottom=UDim.new(0,4)
wordButtons = {}

-- ── BOTTOM BAR ────────────────────────────────
local bottomY = 500 - 44 - 58
local BottomBar = Fr({
    Size=UDim2.new(1,-pad*2,0,54),
    Position=UDim2.new(0,pad,0,bottomY),
    BackgroundColor3=C.card,
}, Body)
Cr(10,BottomBar); Sk(C.border,1.5,BottomBar)
Gd(Color3.fromRGB(14,20,42),Color3.fromRGB(10,14,30),160,BottomBar)

-- Label kata terpilih
Lb({Size=UDim2.new(0.45,0,0,16),Position=UDim2.new(0,10,0,4),
    Text="KATA DIPILIH",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.dim,
    TextXAlignment=Enum.TextXAlignment.Left},BottomBar)

local selectedWordLbl = Lb({
    Size=UDim2.new(0.48,0,0,24),
    Position=UDim2.new(0,10,0,18),
    Text="—", TextSize=16, Font=Enum.Font.GothamBold,
    TextColor3=C.accB, TextXAlignment=Enum.TextXAlignment.Left,
}, BottomBar)

-- Tombol KETIK
local typeBtn = Bt({
    Size=UDim2.new(0,90,0,36),
    Position=UDim2.new(1,-100,0.5,-18),
    BackgroundColor3=C.accD,
    Text="⌨ KETIK",
    TextSize=12, TextColor3=Color3.fromRGB(255,255,255),
    ZIndex=4,
}, BottomBar)
Cr(8,typeBtn); Gd(C.accB,C.accD,90,typeBtn)

typeBtn.MouseButton1Click:Connect(function()
    if not State.selectedWord then
        Notify("Pilih kata dulu!","warn"); return
    end
    Notify("Mengetik: "..State.selectedWord,"ok")
    task.spawn(function()
        TypeWord(State.selectedWord)
    end)
end)

-- ── SETTINGS STRIP (di atas bottom bar) ────────
local settingY = bottomY - 28
local settStrip = Fr({
    Size=UDim2.new(1,-pad*2,0,24),
    Position=UDim2.new(0,pad,0,settingY),
    BackgroundTransparency=1,
}, Body)

-- Human delay toggle
local function SmallTgl(x, label, initVal, cb)
    local on = initVal
    local f = Fr({
        Size=UDim2.new(0,115,1,0),
        Position=UDim2.new(0,x,0,0),
        BackgroundColor3=C.panel,
    }, settStrip)
    Cr(6,f); Sk(C.bF,1,f)
    Lb({Size=UDim2.new(0.65,0,1,0),Position=UDim2.new(0,7,0,0),
        Text=label,TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.muted,
        TextXAlignment=Enum.TextXAlignment.Left},f)
    local pb2=Fr({Size=UDim2.new(0,30,0,16),Position=UDim2.new(1,-36,0.5,-8),BackgroundColor3=Color3.fromRGB(16,20,38)},f); Cr(8,pb2)
    local kn2=Fr({Size=UDim2.new(0,12,0,12),Position=UDim2.new(0,2,0.5,-6),BackgroundColor3=C.muted},pb2); Cr(6,kn2)
    local hit=Bt({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},f)
    local function upd()
        TW:Create(pb2,TweenInfo.new(0.15),{BackgroundColor3=on and C.accD or Color3.fromRGB(16,20,38)}):Play()
        TW:Create(kn2,TweenInfo.new(0.15),{Position=on and UDim2.new(0,16,0.5,-6) or UDim2.new(0,2,0.5,-6),BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted}):Play()
    end
    upd()
    hit.MouseButton1Click:Connect(function()
        on=not on; upd(); cb(on)
    end)
end

SmallTgl(0, "Human Delay", true, function(on)
    State.humanDelay = on
    Notify("Human delay: "..(on and "ON" or "OFF"),"info")
end)
SmallTgl(118, "Jeda Mikir", true, function(on)
    State.thinkDelay = on
    Notify("Jeda mikir: "..(on and "ON" or "OFF"),"info")
end)

-- ── AUTO MODE RUNNER ──────────────────────────
-- Detect kata dari game, auto pilih & ketik
local autoConn
local lastAutoWord = ""

RunService.Heartbeat:Connect(function()
    if not State.autoMode then return end

    -- Throttle: cek tiap 0.5 detik
    if not State._lastAuto then State._lastAuto = 0 end
    local now = os.clock()
    if now - State._lastAuto < 0.5 then return end
    State._lastAuto = now

    -- Detect kata saat ini
    local currentWord = DetectCurrentWord()
    if currentWord and currentWord ~= lastAutoWord and #currentWord >= 2 then
        lastAutoWord = currentWord
        curWordLbl.Text = "Kata: " .. currentWord .. "  →  hrf akhir: " .. currentWord:sub(#currentWord):upper()

        -- Ambil huruf terakhir dari kata sebelumnya
        local lastLetter = currentWord:sub(#currentWord):lower()

        -- Pilih kata terbaik
        local nextWord = BestWordForLetter(lastLetter)
        if nextWord then
            -- Highlight huruf di grid
            if letterBtns[lastLetter] then
                if selectedLetterBtn then
                    TW:Create(selectedLetterBtn,TweenInfo.new(0.15),{BackgroundColor3=C.card,TextColor3=C.muted}):Play()
                end
                selectedLetterBtn = letterBtns[lastLetter]
                TW:Create(selectedLetterBtn,TweenInfo.new(0.15),{BackgroundColor3=C.acc,TextColor3=Color3.fromRGB(255,255,255)}):Play()
                State.activeLetter = lastLetter
            end

            State.selectedWord = nextWord
            selectedWordLbl.Text = nextWord
            wordButtons = {}
            RefreshWordList(lastLetter, "")

            -- Ketik otomatis
            task.spawn(function()
                TypeWord(nextWord)
            end)
            Notify("AUTO → "..nextWord,"ok")
        end
    elseif currentWord then
        curWordLbl.Text = "Kata: " .. currentWord .. "  →  hrf akhir: " .. currentWord:sub(#currentWord):upper()
    end
end)

-- ── ENTRANCE ANIMATION ────────────────────────
W.Position=UDim2.new(0.5,-170,1.5,0)
W.BackgroundTransparency=1
TW:Create(W,TweenInfo.new(0.48,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Position=UDim2.new(0.5,-170,0.5,-250),
    BackgroundTransparency=0,
}):Play()

task.delay(0.5,function()
    Notify("VOID HUB • Sambung Kata loaded!","ok")
    task.delay(1,function()
        Notify("Pilih huruf → pilih kata → KETIK","info")
    end)
end)

-- Init: tampilkan kata awalan A
task.delay(0.8, function()
    if letterBtns["a"] then
        letterBtns["a"]:Activate()
    end
end)
