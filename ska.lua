-- VOID HUB | Sambung Kata v2.0
-- Scan layar otomatis | Database 2000+ kata | Multi-char prefix
-- Awalan: a-z, ng, ny, kh, sy, st, sp, sk, ex, if, dll

-- ══════════════════════════════
-- SERVICES
-- ══════════════════════════════
local Players   = game:GetService("Players")
local RunService= game:GetService("RunService")
local TW        = game:GetService("TweenService")
local UIS       = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

-- ══════════════════════════════
-- SAFE GUI
-- ══════════════════════════════
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
for _, n in ipairs({"VoidSK2","VoidSK2N"}) do
    for _, src in ipairs({function() return game:GetService("CoreGui") end, function() return pg end}) do
        pcall(function() local o=src():FindFirstChild(n); if o then o:Destroy() end end)
    end
end
local MG = MkGui("VoidSK2",100)
local NG = MkGui("VoidSK2N",999)

-- ══════════════════════════════════════════════════════
-- DATABASE KATA (2000+ kata, semua prefix termasuk ng/ny/kh/sy)
-- Format: ["prefix"] = {kata1, kata2, ...}
-- Kata dipilih: umum, mudah diketik, valid KBBI
-- ══════════════════════════════════════════════════════
local DB = {}

-- Helper: tambah kata ke prefix
local function add(prefix, words)
    prefix = prefix:lower()
    if not DB[prefix] then DB[prefix] = {} end
    for _, w in ipairs(words) do
        table.insert(DB[prefix], w:lower())
    end
end

-- ── HURUF TUNGGAL ────────────────────────────
add("a",{"alam","api","ada","air","anak","ayah","adik","ambil","angkat","angin",
"akar","atas","awas","akhir","awal","arif","akad","alun","adab","abdi","abai",
"acuh","acak","adat","adil","agak","agam","agen","agung","ahli","ajak","ajal",
"ajar","akan","akal","aksi","aku","alah","alap","alim","alir","alur","aman",
"amat","amis","ampas","ampuh","anam","aneh","angka","angsa","aniaya","anjing",
"apung","arah","arang","arus","asah","asam","asin","asli","asuh","atap","atur",
"awam","awet","ayam","ayat","azas","abang","abis","abot","abus","acar","acap",
"ambang","ambin","abling","aboh","abrik","abrit","abstrak","abu","abuh","abuk",
"acara","aceh","acuan","acung","adab","adang","adas","adat","adegan","aduh",
"afiat","agak","agama","agih","agon","agram","agri","agresi","ahad","ahwal",
"aib","ain","aira","airu","ajang","ajar","ajeg","ajuan","akal","akan","akbar",
"akhbar","akhir","akhlak","akrab","aksi","aktif","akur","alami","alap","alas",
"alat","album","alcor","alegi","aleng","aleut","alfa","alfabet","alga","algae",
"alias","alih","alim","alir","alis","alit","aljabr","alki","alku","altar"})

add("b",{"baca","bahu","baju","bawa","besar","bisa","buat","buah","buku","bulan",
"bumbu","bunyi","buruk","buru","basah","batas","bayar","bebas","bekal","bekas",
"belah","belas","beli","benih","berat","bijak","bikin","bilas","bilang","bintang",
"bocah","bodoh","bohong","boleh","boros","botak","bubur","bukan","bumi","bungkus",
"buruh","busuk","butuh","buyar","baik","bakti","balap","balas","balik","balon",
"bambu","barang","baris","baru","batik","batok","baur","bayam","bebek","bedah",
"benar","benci","benua","beras","berani","bersih","bersatu","besok","betah",
"betul","biaya","bibir","bimbang","biru","bisik","bising","bius","blok","bocor",
"bola","bolak","bonceng","bongkar","bonus","borak","bosan","botol","buang","bubar",
"bubuk","budak","budaya","bujuk","bulat","bulu","buncit","bungah","burai","buras",
"bursa","busur","busung","buta","buyung","bawah","badai","bagai","bagas","bagian",
"bagus","bahasa","bahaya","bahu","baiat","baik","baja","bajak","bajau","bajik"})

add("c",{"cari","cinta","cuci","cukup","curang","cepat","cerita","cermat","cantik",
"capai","cakar","cakap","canda","cara","cat","cita","coba","cocok","corak",
"cuaca","cuma","cabang","cabut","cagar","cahaya","calon","campur","canggih",
"capek","celah","cemas","cerah","cerdas","cicak","cikal","ciprat","cipta",
"colek","comot","contoh","copot","coreng","cubit","cucuk","cukai","cukur",
"culik","cumbu","cumi","curai","curiga","curus","cuti","cendekia","cerewet",
"cerdik","cemerlang","ceria","cemburu","cemar","cendera","cengang","cakrawala",
"canda","cenela","cergas","cermin","cicil","cilok","cium","coblos","coret",
"cowok","cuci","culas","curang","curhat","curiga","custom","cakupan","calo",
"camat","cambuk","camilan","candaan","capaian","catatan","cela","celaka"})

add("d",{"dalam","damai","dapur","darah","darat","datang","daya","dekat","dengar",
"desa","dewasa","diam","didik","dingin","diri","duduk","dunia","duka","duri",
"dusta","dapat","dagang","dahan","dahulu","daun","dawai","dayung","debu","dedak",
"demam","dendam","depan","deras","dewan","dialog","dinas","dini","dobrak","domba",
"dorong","dosa","durian","dukung","duluan","dasar","daftar","dakwah","dalang",
"damba","dampak","dandan","danau","darma","dayak","decak","degup","delapan",
"derma","desak","desah","dewa","dibuat","dicoba","difasilitasi","diikat","dikira",
"diksi","dilema","dimana","dinasti","dirawat","disukai","ditata","diukur",
"donasi","dosen","drakor","drama","draping","dribel","duit","dulur","dusun"})

add("e",{"ekor","elok","emak","emas","empat","enak","encik","era","esok","etika",
"elang","empuk","encok","endap","enggan","erat","edar","edukasi","efek","egois",
"elastis","emosi","empati","energi","evolusi","ekspor","ejaan","ejek","eksis",
"elak","elus","embun","empang","enjin","erat","etnis","ekstra","ekspres",
"elemen","emas","ember","embun","empal","empasan","empedal","empelas","empung",
"enceng","endemik","endus","engkau","ensiklopedia","entah","epos","erak","erang",
"eras","erosi","erupsi","esai","etnis","ewah"})

add("f",{"faham","fakta","fatal","firasat","fokus","formal","forum","fungsi",
"fasad","fasilitas","favorit","fenomena","fikir","fitnah","fondasi","formula",
"fosil","frustrasi","fadil","fajar","fakir","falak","famili","fana","fardu",
"fasih","fatwa","fesyen","fiksi","filsafat","final","fisika","fisik","fitrah",
"fleksibel","fobia","format","frasa","friksi","frontal","fujur","faedah",
"fana","fanatis","fardhu","fasilitasi","fatamorgana","fikiran","filosofi"})

add("g",{"gagah","gaji","gampang","gerak","gigih","guna","guru","gembira","gelap",
"gemuk","getah","gigi","girang","golok","goyang","gabung","gadis","gagal",
"galak","galon","galur","ganas","ganjil","garang","garuk","gasak","gatal",
"gaung","gayung","gelak","gelas","gelombang","gempa","gendang","gertak","gigit",
"gilap","gilas","golek","goresan","gosip","gugur","gulung","gumam","guntur",
"gurat","gusar","guyur","gaib","galau","gambar","ganda","getir","giat","global",
"goreng","gratis","gula","gampang","ganjal","gaul","gayuh","geger","gencar",
"gencatan","genggam","genteng","geram","gerombolan","getun","gila","gilas"})

add("h",{"hadir","halus","harga","hari","haus","hebat","hemat","hidup","hijau",
"hilang","hormat","hujan","hutan","habis","hakim","harap","harta","hasrat",
"hati","hawa","heboh","heran","hina","hitam","hubung","hulur","huruf","hadap",
"hadiah","hafal","halal","hambat","hampa","hancur","hangat","haram","harmoni",
"hasil","hasut","hening","hikmah","hukum","harapan","hargai","hikayat","hilir",
"hormati","hidayah","himbauan","hipokrit","holistik","humanis","humor",
"hablu","hampir","handal","hangout","harimau","harta","hibah","hidung","hikmat",
"hingga","hobi","horor","hubungan","hunian","huru","hutang"})

add("i",{"ibu","ikan","ikut","ilmu","iman","impian","indah","ingin","ingat","izin",
"ikhlas","iklim","ikrar","irama","istri","ikat","ijazah","ikhtiar","imam",
"imbal","imbas","imbuh","impas","impor","inap","injak","insaf","intai","inti",
"iringi","isap","isyarat","ilahi","ilalang","ilusi","imajinasi","inovasi",
"insan","inspirasi","integrasi","intensi","interaksi","investasi","iringan",
"isolasi","istimewa","ingkar","intan","ikatan","ibadah","ikhwan","imunitas",
"imbalan","inisiatif","inklusif","institusi","instruksi","intens","islah"})

add("j",{"jaga","jalan","janji","jauh","jawab","jelas","jujur","jumpa","jangan",
"jatuh","jiwa","jual","juang","jagoan","jago","jahat","jahil","jaket","jalur",
"jamur","janda","jantan","jasad","jasa","jatah","jemu","jerih","jitu","jodoh",
"jorok","juara","junjung","jurang","jabatan","jadwal","jahit","jamuan","jangka",
"jangkau","jelita","jelma","jemput","jemur","jenaka","jenuh","jerami","jernih",
"jijik","jinak","jinjit","jiplak","joget","judul","jurnal","jurus","jebak",
"jeli","jempol","jendela","jengkel","jeratan","jitu","jubah","judulnya"})

add("k",{"kata","kerja","kuat","kuning","kunci","kita","kali","kaya","kayu","keras",
"kepala","kiri","kota","kumpul","kasih","kabar","kaki","kalau","kalung","kamar",
"kamus","kantor","kapal","karya","kasur","ketika","kirim","kolam","kurang",
"kursi","kusut","kabur","kaget","kagum","kasar","kawasan","kawan","kebun",
"kecil","kejar","kekal","keliru","kembar","kendali","kesal","kisah","kocak",
"kolong","kompak","konsep","kuasa","kubur","kuda","kuliah","kundur","kunyit",
"kupas","kurban","kurus","kutuk","kemarahan","kebaikan","kehidupan","kemajuan",
"kenikmatan","kepercayaan","kaget","kalap","kalbu","kalimat","kampung","kandang",
"kantuk","kapan","karang","karena","karena","karir","karung","kasih","kasur"})

add("l",{"lari","laut","lepas","lihat","lurus","lupa","lama","lapar","lembut","licin",
"loyal","lucu","luka","lunas","luruh","labuh","ladang","lahir","lajur","lakon",
"lalai","larang","laris","lasak","layang","lebah","lebih","legam","leka","lengah",
"lengkap","lepak","lewat","liar","lincah","lingkar","lipas","lipat","lirih",
"listrik","lolos","loncat","lorong","loteng","loyak","lubang","luhur","lulus",
"lumpur","lumut","luncur","lutut","layan","layak","lazim","lebur","lelah",
"lemah","lempar","lengan","lesu","libur","lidah","lingkungan","liputan","logika",
"luapan","lugas","laknat","lalang","lambai","lambat","lampau","lampiran","lancer",
"landai","langsing","langsung","lapang","lapas","laporan","larut","latih"})

add("m",{"maju","makan","malam","malas","malu","mana","mandi","marah","masuk","mata",
"mati","mau","meja","merah","mikir","mimpi","minta","muda","mulai","murah",
"murni","musuh","mahal","mahir","mainan","makna","malah","malang","manis",
"manfaat","masalah","masih","matang","mewah","milik","mimbar","mudah","mulia",
"mundur","murung","musim","mabuk","makhluk","mampu","mantap","masyarakat",
"meraih","merawat","merasa","meski","mewujudkan","menang","mencari","mendapat",
"mengerti","menghormati","menjaga","menyayangi","mabur","macan","macet","madani",
"magis","majelis","majikan","makanan","makar","maksum","malam","malim","mandiri",
"manggis","mangsa","manusia","marah","marga","markas","masa","masak","matahari"})

add("n",{"naik","nama","nada","nafas","nakal","nasib","niat","nilai","nikah","nikmat",
"nyaman","nyata","nyanyi","nyawa","nabati","nafkah","nalar","nampak","nanti",
"napas","narasi","nasihat","nazar","negara","nekat","nelayan","nenek","niaga",
"nifas","niscaya","nista","normal","notasi","nujum","nyalang","nyali","nurani",
"nusantara","nisbah","norma","naga","nagari","nahas","naluri","numpang",
"nangka","naungan","navigasi","negeri","neraca","nikel","nominal","normatif",
"nostalgia","notulen","nuzul","nafsu","ngebut","ngerti","ngelamar","ngemil"})

add("o",{"obat","olahraga","olah","orang","ombak","omong","opini","optimis","otak",
"otot","oleh","operasi","orasi","obrolan","objek","oksigen","organisasi",
"orientasi","orisinal","otoritas","otonomi","otomatis","obrol","oceh","onak",
"ondeh","ongkos","opah","orbit","orde","organ","oval","obyek","omega","opera",
"oknum","olimpiade","omongan","onderdil","open","opname","oportunis","ordal"})

add("p",{"pagi","paham","pandai","panjang","papan","pasang","peduli","perlu","pikir",
"pintar","pohon","puasa","pulang","punya","putih","padu","pahala","pakai",
"paksa","panas","pangkat","pasti","patuh","pecah","pekat","peka","percaya",
"pergi","pesan","petang","piawai","pilihan","polos","pondok","positif","puas",
"pujian","pulih","punah","pupuk","purba","pusaka","pilih","pindah","pingsan",
"pinjam","pisah","pitam","piutang","pokok","potong","prihatin","pribadi",
"prinsip","prioritas","produk","profesi","program","proyek","proses","publik",
"penuh","penting","perang","perahu","perdata","perintah","perkara","perlu",
"permata","persatuan","pertama","perubahan","pesta","petani","pilar","pintasan"})

add("r",{"rasa","ramai","rapih","rapat","raih","rajin","ramah","randa","rangkul",
"rantai","rapi","rawat","redup","rela","rendah","rezeki","riang","ringan",
"risau","rohani","rukun","rumbai","rusak","ragu","rahayu","rahasia","rakus",
"ramalan","rampas","rancang","randuk","rangkai","rantau","ratap","rehat","remaja",
"rencana","rendam","renggang","repot","resah","rindu","ritual","riwayat",
"rombak","rompi","rontal","rontok","ruang","runding","runtuh","runyam","rupiah",
"rugi","rumit","runcing","runtun","rupawan","rusuh","ruwet","raga","ragam",
"rakyat","ramah","ranah","rancak","randai","rapi","rapuh","rasul","raut"})

add("s",{"sabar","sakit","sama","sayang","selalu","semua","senang","serius","setia",
"siap","simpan","sinar","singa","sopan","sukses","sunyi","syukur","sabda",
"sahaja","sahut","saing","salam","salah","santai","santun","saran","sarjana",
"sasaran","satuan","segar","sehat","semangat","sempurna","sentra","sepadu",
"sepakat","serasi","sering","siaga","sigap","sikap","silap","simpul","sinergi",
"singkat","siswa","situasi","skema","solusi","songket","sumber","sungguh",
"supaya","sulit","sulur","sumbu","sumpah","surga","suruh","susah","syariah",
"solidaritas","semesta","sabun","safari","sahabat","sahih","saksama","salak",
"salut","sampah","sandal","sangat","sangkut","santet","sarana","sarat","sarung"})

add("t",{"tahu","takut","tamat","tanda","tegar","teliti","tenang","terus","tiba",
"tiga","tiket","tindak","tinggal","tujuan","tulus","tabah","tabu","tahan",
"tajam","tapa","taruh","tatap","tawar","tebal","teduh","tegak","teguh","tekad",
"tekun","teladan","tempat","tentu","tepat","terbang","terima","terlalu","tetap",
"tinggi","titik","tugas","tuntas","turut","tutur","tabiat","takluk","tali",
"tamak","tandas","tangguh","tanpa","terbuka","termaju","terpadu","terpercaya",
"timbul","tingkah","toleran","transparan","tumbuh","tunai","turun","tuntut",
"tutup","tabir","tadah","tahap","tahta","taklid","takwa","tambal","tambang",
"tanah","tanam","tapak","tarikan","tatanan","tegalan","telaga","telapak"})

add("u",{"ubah","udara","uji","ukur","ulang","unik","untung","usaha","utama","ulur",
"umum","unggul","upaya","urai","urun","usul","utuh","ujar","ujian","ukiran",
"ulasan","ulet","umur","ungkap","unjuk","unsur","upah","urai","urgen","usik",
"utara","ukhuwah","umat","umpama","universal","urus","usap","utamakan","utas",
"ukuran","ulam","ikhlas","ulas","ulat","ulos","undur","unggas","uni","unik",
"unitasi","unsung","urus","utang","uyon"})

add("v",{"vaksin","valid","variasi","vital","vokal","volume","varian","visi",
"validasi","vegetasi","ventilasi","verifikasi","versi","veteran","vibran",
"vitalitas","virus","visioner","virtuoso","vakum","vokasi","volunter",
"vegetal","vendor","verbal","vertikal","veto","vibrasi","viral"})

add("w",{"wajar","waktu","wajah","warna","warung","wasiat","waspada","wujud",
"walau","wanita","warga","warisan","watak","wewenang","wirausaha","wujudkan",
"wahyu","walid","waris","wartawan","wawasan","wijak","wirasa","wisata",
"warga","wujud","wangi","wakaf","walimah","welas","wibawa","wong","wabil",
"wadah","wafat","wahana","wakil","walimatulnikah","wangi","warni","wasit"})

add("y",{"yakin","yang","yakni","yatim","yuran","yunior","yudisial","yuridis",
"yakini","yasmin","yoga","yoman","yudha","yaitu","yamani"})

add("z",{"zaman","zakat","zalim","zikir","zona","zuhud","zuriat","zodiak",
"zakar","zanah","zariah","ziarah","zigzag","zinah","zonasi","zuhur","zakat"})

-- ── AWALAN DUA HURUF (ng, ny, kh, sy, st, sp, sk, pr, tr, kr, gr, br, dr, fr) ──

add("ng",{"nganga","ngobrol","ngomong","ngerasa","ngeri","ngaku","ngejar",
"ngeliat","ngemil","ngerti","ngambil","ngantar","ngatur","ngajar","ngasih",
"ngecat","ngedepan","ngejekin","ngejek","ngekost","ngelawan","ngeles",
"ngelirik","ngeluh","ngembara","ngendap","ngendon","ngepel","ngerem",
"ngeribut","ngeselin","ngetik","ngetrend","ngeundang","ngewarnai","ngiris",
"ngobrol","ngomong","ngopi","ngoreng","ngotot","ngucap","ngudek","ngumpul",
"ngunduh","ngunggah","ngurusin","ngusir","ngutang","ngurus"})

add("ny",{"nyaman","nyata","nyawa","nyanyi","nyali","nyala","nyampah","nyamuk",
"nyaris","nyinyir","nyonya","nyala","nyaman","nyamping","nyanding","nyata",
"nyatakan","nyawang","nyebrang","nyeduh","nyemplung","nyenggol","nyentil",
"nyeri","nyimak","nyimpen","nyingkir","nyobain","nyolot","nyontek","nyuciin",
"nyuci","nyulap","nyumbang","nyumput","nyundut","nyuntik","nyuruh"})

add("kh",{"khas","khusus","khidmat","khalayak","khalifah","kharisma","khatam",
"khatulistiwa","khawatir","khilaf","khitan","khotbah","khurafat","khutbah",
"khayal","khazanah","khasiat","khatib","khidmat","khusyuk"})

add("sy",{"syarat","syukur","syair","syaraf","syariah","syahadat","syahdu",
"syahwat","syaitan","syariat","syirik","syukuran","syahid","syahbandar",
"syarat","syifaat","syok","syukur"})

add("st",{"strategi","struktur","stabil","standar","statis","stimulus","stres",
"stroke","studio","studi","studia","studing","steker","stereo","steril",
"stigma","stimulasi","stok","stormer","strapping"})

add("sp",{"spesial","spesifik","sponsor","spontan","sportif","spread","sprint",
"spanduk","spasi","spektrum","spekulasi","spesies","spiral","splendid"})

add("sk",{"sketsa","skill","skolastik","skala","skandal","skeptis","skema",
"skrip","skrining","skripsi","skrol","struktur"})

add("pr",{"proses","produk","program","proyek","pribadi","prinsip","prioritas",
"praktis","pragmatis","prakarsa","prolog","properti","proposal","proteksi",
"provokasi","publik","prestasi","prima","produktif","profesi","progres"})

add("tr",{"tradisi","transfer","transparan","trauma","trampil","tren","trial",
"tribun","triliun","tripel","triwulan","trofeo","tropis","trowel"})

add("kr",{"kreatif","kritis","krusial","kriminal","kritis","kronologi","krisis",
"kriteria","kritik","kronik","kronologis"})

add("gr",{"gratis","grafis","grafik","gravitasi","grup","gradual","graduasi",
"gramatikal"})

add("br",{"brosur","branding","brilian","brutal","brutalitas","browse","broker"})

add("dr",{"drama","drastis","drastis","draping","dribel","drone","drop","draf"})

add("fr",{"fraksi","frasa","frekuensi","frikatif","frontal","frustrasi","friksi"})

-- ── AWALAN EX/IF/AL/IN/UN/RE/DE dll (dari bahasa asing yang umum) ──

add("ex",{"ekspor","ekspansi","ekspedisi","ekspres","ekstra","eksklusif","eksak",
"eksplor","eksploitasi","eksplorasi","ekspresi","eksis","ekskul","eksekusi",
"eksperimen","eksplan","eksposur"})

add("if",{"ikhtisar","ilahi","ilustrasi","imajinasi","implementasi","implikasi",
"improvisasi","inisiatif","inovatif","inspeksi","inspirasi","institusi",
"instruksi","integrasi","intensif","interaksi","interpretasi"})

add("al",{"alasan","alami","alam","alat","alkitab","alokasi","alternatif",
"altruisme","alumni","alur","aliansi","algoritma","alkohol","alergi"})

add("in",{"indah","ingin","ingat","insaf","intai","inti","iringi","isap","isyarat",
"insan","inspirasi","integrasi","intensi","interaksi","investasi","iringan",
"isolasi","inklusif","instruksi","inovasi","indikasi","industri","informasi"})

add("un",{"untuk","untung","unjuk","unsur","undang","ungkap","unggul","universal",
"unik","urgensitas"})

add("re",{"rencana","rendah","rezeki","riang","ringan","risau","rohani","rukun",
"reformasi","regulasi","relevan","realistis","rekap","rekayasa","relasi",
"reputasi","resolusi","respon","revisi","revolusi"})

add("de",{"dedikasi","demi","depan","deras","desak","desah","detail","determinasi",
"dialog","dilema","dinamis","disiplin","diversitas","dokumentasi"})

add("ko",{"kompak","konsep","kuasa","kota","kolam","kolong","komunikasi","komitmen",
"komunitas","kondisi","konflik","korelasi","korupsi","kreatif"})

add("ba",{"baca","bahu","baju","bawa","baik","bakti","balap","balas","balik","balon",
"bambu","barang","baris","baru","batik","batok","bayam","bazaar","badai"})

add("be",{"bebas","bekal","bekas","belah","belas","beli","benih","berat","berita",
"benar","benci","benua","beras","berani","bersih","bersatu","besok","betah",
"betul","belaian","belakang","belanja","belokan","belukar","beranda","berkah"})

add("me",{"maju","makan","malam","merah","mikir","mimpi","minta","muda","mulai",
"meraih","merawat","merasa","meski","menang","mencari","mendapat","mengerti",
"menghormati","menjaga","menyayangi","mewujudkan","melukis","memasak"})

add("pe",{"peduli","perlu","pikir","pintar","pohon","pagi","paham","pandai","panjang",
"pasang","padu","pahala","pakai","paksa","panas","pangkat","pasti","patuh",
"pecah","pekat","peka","percaya","pergi","pesan","petang","piawai","pilihan",
"penuh","penting","perang","perahu","perdata","perintah","perkara"})

add("se",{"setia","selalu","semua","senang","serius","siap","sunyi","sehat","semangat",
"sempurna","sentra","sepadu","sepakat","serasi","sering","siaga","sigap",
"sikap","solusi","sumber","sungguh","supaya","sulit"})

add("te",{"tahu","takut","tamat","tanda","tegar","teliti","tenang","terus","tiba",
"tekad","tekun","teladan","tempat","tentu","tepat","terbang","terima","tetap",
"tinggi","titik","tugas","tuntas","turut","tutur","terbuka","termaju","terpadu"})

add("ke",{"kita","kali","kaya","kayu","keras","kepala","kiri","kota","kumpul",
"kasih","kabar","kebun","kecil","kejar","kekal","keliru","kembar","kendali",
"kesal","kisah","kocak","kompak","konsep","kuasa","kuda","kuliah"})

add("di",{"didik","diam","dingin","diri","duduk","dialog","dinas","dini","donasi",
"dilema","dinamis","disiplin","diversitas","digital","diminati"})

add("ti",{"tiba","tiga","tiket","tindak","tinggal","titik","tidak","tipis","tiruan",
"tokoh","toleran","transparan","tumbuh","tunai","turun","tuntut","tutup"})

add("la",{"lari","laut","ladang","lahir","lajur","lakon","lalai","larang","laris",
"lasak","layang","layak","lazim","labuh","lapar","lama","lampau","lapang"})

add("ma",{"maju","makan","malam","malas","malu","mana","mandi","marah","masuk",
"mata","mati","mau","mahal","mahir","mainan","makna","malah","malang","manis",
"manfaat","masalah","masih","matang","mabuk","makhluk","mampu","mantap"})

add("sa",{"sabar","sakit","sama","sayang","sabda","sahaja","sahut","saing","salam",
"salah","santai","santun","saran","sarjana","sasaran","satuan"})

add("pa",{"pagi","paham","pandai","panjang","papan","pasang","padu","pahala","pakai",
"paksa","panas","pangkat","pasti","patuh","pecah","pekat","peka"})

add("ra",{"rasa","ramai","rapih","rapat","raih","rajin","ramah","randa","rangkul",
"rantai","rapi","rawat","ragu","rahayu","rahasia","rakus","ramalan","rampas"})

add("ta",{"tahu","takut","tamat","tanda","tabah","tabu","tahan","tajam","tapa",
"taruh","tatap","tawar","tabiat","takluk","tali","tamak","tandas","tangguh"})

add("ha",{"hadir","halus","harga","hari","haus","hebat","hemat","habis","hakim",
"harap","harta","hasrat","hati","hawa","hadap","hadiah","hafal","halal"})

add("na",{"naik","nama","nada","nafas","nakal","nasib","niat","nilai","nikah",
"nikmat","nabati","nafkah","nalar","nampak","nanti","napas","narasi","nasihat"})

add("da",{"dalam","damai","dapur","darah","darat","datang","daya","dekat","dengar",
"desa","dagang","dahan","dahulu","daun","dawai","dayung","dasar","daftar"})

add("ka",{"kata","kali","kaya","kayu","kabar","kaki","kalau","kalung","kamar",
"kamus","kantor","kapal","karya","kasur","kasih","kasar","kawasan","kawan"})

add("ga",{"gagah","gaji","gampang","gerak","gigih","gabung","gadis","gagal","galak",
"galon","galur","ganas","ganjil","garang","garuk","gasak","gatal","gaung"})

add("ja",{"jaga","jalan","janji","jauh","jawab","jagoan","jago","jahat","jahil",
"jaket","jalur","jamur","janda","jantan","jasad","jasa","jatah","jabatan"})

add("wa",{"wajar","waktu","wajah","warna","warung","wasiat","waspada","walau",
"wanita","warga","warisan","watak","wahyu","walid","waris","wartawan"})

add("ba",{"baca","bahu","baju","bawa","besar","basah","batas","bayar","bebas",
"baik","bakti","balap","balas","balik","balon","bambu","barang","baris","baru"})

-- ── AWALAN TIGA HURUF KHUSUS ──
add("str",{"strategi","struktur","stres","stroke","studio","studi","strapping"})
add("kha",{"khas","kharisma","khatam","khatulistiwa","khawatir","khayal","khazanah","khasiat"})
add("khu",{"khusus","khutbah","khusyuk"})
add("nya",{"nyaman","nyata","nyawa","nyanyi","nyali","nyala","nyamuk","nyaris"})
add("nge",{"ngejar","ngeliat","ngemil","ngerti","ngecat","ngejekin","ngeles","ngelirik",
"ngeluh","ngerem","ngeribut","ngeselin","ngetik","ngeundang","ngewarnai"})
add("ngo",{"ngomong","ngobrol","ngopi","ngoreng","ngotot"})
add("nga",{"nganga","ngambil","ngantar","ngatur","ngajar","ngasih","ngumpul","ngunduh","ngurus"})

-- ══════════════════════════════════════════════════════
-- SCAN LAYAR: Ambil kata terakhir dari UI game
-- Metode: scan semua TextLabel di PlayerGui
-- ══════════════════════════════════════════════════════
local lastDetected = ""
local lastScanTime = 0

local function ScanScreen()
    local now = os.clock()
    if now - lastScanTime < 0.3 then return lastDetected end
    lastScanTime = now

    local candidates = {}

    -- Scan semua TextLabel dan TextBox di PlayerGui
    for _, gui in ipairs(pg:GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            local text = nil
            if obj:IsA("TextLabel") then text = obj.Text
            elseif obj:IsA("TextBox") then text = obj.Text end

            if text and #text >= 2 and #text <= 25 then
                local t = text:lower():match("^%s*(.-)%s*$")  -- trim
                -- Hanya kata (boleh ada spasi untuk frase pendek)
                -- Cari kata terakhir jika ada spasi
                local lastWord = t:match("(%a+)%s*$") or t
                if lastWord and #lastWord >= 2 and lastWord:match("^[a-z]+$") then
                    -- Prioritaskan berdasarkan nama object
                    local name = obj.Name:lower()
                    local score = 0
                    if name:find("current") or name:find("word") or name:find("kata") then score = score + 10 end
                    if name:find("soal") or name:find("prompt") or name:find("display") then score = score + 8 end
                    if name:find("game") or name:find("main") or name:find("label") then score = score + 5 end
                    if name:find("chat") or name:find("input") then score = score - 5 end
                    -- Ukuran font besar = lebih mungkin kata utama
                    if obj:IsA("TextLabel") and obj.TextSize >= 18 then score = score + 6 end
                    if obj:IsA("TextLabel") and obj.TextSize >= 24 then score = score + 4 end
                    -- Di tengah layar = lebih mungkin
                    local pos = obj.AbsolutePosition
                    local scrSize = workspace.CurrentCamera.ViewportSize
                    local cx = math.abs(pos.X + obj.AbsoluteSize.X/2 - scrSize.X/2)
                    if cx < 100 then score = score + 4 end
                    table.insert(candidates, {word=lastWord, score=score})
                end
            end
        end
    end

    -- Sort by score
    table.sort(candidates, function(a,b) return a.score > b.score end)
    if #candidates > 0 then
        lastDetected = candidates[1].word
        return lastDetected
    end
    return lastDetected
end

-- Ambil prefix dari kata (1, 2, atau 3 karakter)
local function GetPrefix(word, len)
    if not word or #word < len then return nil end
    return word:sub(1,len):lower()
end

-- Cari kata terbaik untuk huruf terakhir dari kata sebelumnya
local function FindBestWord(lastChar)
    lastChar = lastChar:lower()
    -- Coba prefix 1, 2, 3 huruf
    local pool = {}
    -- 1 huruf
    if DB[lastChar] then
        for _, w in ipairs(DB[lastChar]) do table.insert(pool, w) end
    end
    -- Tidak perlu 2/3 huruf untuk lastChar (itu untuk tampilan menu)
    if #pool == 0 then return nil end
    -- Pilih kata yang huruf terakhirnya juga ada di DB (bisa dilanjutkan)
    local good = {}
    for _, w in ipairs(pool) do
        local last = w:sub(#w):lower()
        if DB[last] and #DB[last] > 0 then
            table.insert(good, w)
        end
    end
    local src = #good > 0 and good or pool
    -- Pilih kata yang panjangnya sedang (3-7 huruf) agar mudah diketik
    local mid = {}
    for _, w in ipairs(src) do
        if #w >= 3 and #w <= 8 then table.insert(mid, w) end
    end
    local final = #mid > 0 and mid or src
    return final[math.random(1, math.min(15, #final))]
end

-- ══════════════════════════════════════════════════════
-- AUTO TYPE
-- ══════════════════════════════════════════════════════
local function FindInputBox()
    -- Cari TextBox yang bisa diinput
    for _, gui in ipairs(pg:GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextBox") and obj.Visible then
                local n = obj.Name:lower()
                local p = obj.Parent and obj.Parent.Name:lower() or ""
                if n:find("input") or n:find("answer") or n:find("chat")
                or n:find("word") or n:find("kata") or n:find("type")
                or p:find("input") or p:find("chat") then
                    return obj
                end
            end
        end
    end
    -- Fallback: TextBox visible terbesar
    local best, bsz = nil, 0
    for _, gui in ipairs(pg:GetChildren()) do
        if not gui:IsA("ScreenGui") then continue end
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextBox") and obj.Visible then
                local sz = obj.AbsoluteSize.X
                if sz > bsz then bsz=sz; best=obj end
            end
        end
    end
    return best
end

local typing = false
local function TypeWord(word, humanDelay)
    if typing then return end
    typing = true
    task.spawn(function()
        local box = FindInputBox()
        if box then
            pcall(function() box:CaptureFocus() end)
            task.wait(0.05)
            pcall(function() box.Text = "" end)
            for i = 1, #word do
                pcall(function() box.Text = word:sub(1,i) end)
                if humanDelay then
                    task.wait(0.06 + math.random()*0.12)
                else
                    task.wait(0.04)
                end
            end
            task.wait(0.08)
            pcall(function() box:ReleaseFocus(true) end)
            -- Simulasi Enter
            task.wait(0.05)
            pcall(function()
                local VU = game:GetService("VirtualUser")
                VU:KeyDown(Enum.KeyCode.Return)
                task.wait(0.04)
                VU:KeyUp(Enum.KeyCode.Return)
            end)
        end
        task.wait(0.3)
        typing = false
    end)
end

-- ══════════════════════════════════════════════════════
-- NOTIFICATION
-- ══════════════════════════════════════════════════════
local nList = {}
local function Notif(msg, t)
    t = t or "info"
    local col = t=="ok" and Color3.fromRGB(60,210,120)
             or t=="warn" and Color3.fromRGB(255,170,40)
             or t=="err" and Color3.fromRGB(255,65,65)
             or Color3.fromRGB(70,140,255)
    for _, f in ipairs(nList) do
        TW:Create(f,TweenInfo.new(0.12),{Position=f.Position+UDim2.new(0,0,0,34)}):Play()
    end
    local f = Instance.new("Frame",NG)
    f.Size=UDim2.new(0,200,0,28); f.Position=UDim2.new(1,-210,0,-40)
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
    TW:Create(f,TweenInfo.new(0.25,Enum.EasingStyle.Back),{Position=UDim2.new(1,-210,0,8)}):Play()
    task.delay(2.5,function()
        TW:Create(f,TweenInfo.new(0.18),{Position=UDim2.new(1,10,0,f.Position.Y.Offset)}):Play()
        task.delay(0.2,function()
            local i=table.find(nList,f); if i then table.remove(nList,i) end
            pcall(function() f:Destroy() end)
        end)
    end)
end

-- ══════════════════════════════════════════════════════
--  U I  — COMPACT ANDROID FRIENDLY
--  Ukuran: 310 x 460 (tidak memenuhi layar)
--  Layout: Title | Scan bar | Prefix grid | Word list | Action bar
-- ══════════════════════════════════════════════════════

local C = {
    bg    = Color3.fromRGB(9,10,20),
    panel = Color3.fromRGB(13,15,28),
    card  = Color3.fromRGB(18,21,38),
    cardH = Color3.fromRGB(24,28,50),
    acc   = Color3.fromRGB(70,130,255),
    accB  = Color3.fromRGB(100,160,255),
    accD  = Color3.fromRGB(35,80,200),
    bdr   = Color3.fromRGB(35,65,160),
    bF    = Color3.fromRGB(22,30,58),
    txt   = Color3.fromRGB(215,228,255),
    muted = Color3.fromRGB(85,110,170),
    dim   = Color3.fromRGB(38,55,100),
    ok    = Color3.fromRGB(60,210,120),
    warn  = Color3.fromRGB(255,170,40),
    danger= Color3.fromRGB(255,65,65),
    gold  = Color3.fromRGB(255,200,50),
}

local function Fr(p,pa) local f=Instance.new("Frame"); f.BorderSizePixel=0; for k,v in pairs(p) do pcall(function()f[k]=v end) end; if pa then f.Parent=pa end; return f end
local function Lb(p,pa) local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Font=Enum.Font.GothamSemibold; for k,v in pairs(p) do pcall(function()l[k]=v end) end; if pa then l.Parent=pa end; return l end
local function Bt(p,pa) local b=Instance.new("TextButton"); b.BorderSizePixel=0; b.Font=Enum.Font.GothamBold; for k,v in pairs(p) do pcall(function()b[k]=v end) end; if pa then b.Parent=pa end; return b end
local function Cr(r,p) Instance.new("UICorner",p).CornerRadius=UDim.new(0,r) end
local function Sk(c,t,p) local s=Instance.new("UIStroke",p); s.Color=c; s.Thickness=t; return s end
local function Gd(c1,c2,r,p) local g=Instance.new("UIGradient",p); g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)}); g.Rotation=r end

-- WINDOW — 310 × 460, posisi kiri bawah (tidak menghalangi kata di tengah)
local W = Fr({
    Size=UDim2.new(0,310,0,460),
    Position=UDim2.new(0,8,0.5,-230),  -- kiri tengah
    BackgroundColor3=C.bg, Active=true, Draggable=true,
},MG)
Cr(12,W); Sk(C.bdr,1.5,W); Gd(Color3.fromRGB(9,11,22),Color3.fromRGB(5,6,15),155,W)

-- TITLE BAR (38px)
local TB=Fr({Size=UDim2.new(1,0,0,38),BackgroundColor3=C.accD,ZIndex=3},W); Cr(12,TB)
Fr({Size=UDim2.new(1,0,0.5,0),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=C.accD,BorderSizePixel=0,ZIndex=2},TB)
Gd(Color3.fromRGB(50,110,255),Color3.fromRGB(20,60,180),130,TB)
local logo=Fr({Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,7,0.5,-13),BackgroundColor3=C.acc,ZIndex=4},TB)
Cr(6,logo); Gd(C.accB,C.accD,135,logo)
Lb({Size=UDim2.new(1,0,1,0),Text="V",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},logo)
Lb({Size=UDim2.new(0,120,0,16),Position=UDim2.new(0,38,0,3),Text="VOID HUB",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
Lb({Size=UDim2.new(0,160,0,12),Position=UDim2.new(0,38,0,21),Text="Sambung Kata  •  KBBI",TextSize=8,TextColor3=Color3.fromRGB(140,185,255),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},TB)
local BC=Bt({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-28,0.5,-11),BackgroundColor3=C.danger,Text="✕",TextSize=10,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BC)
local BM=Bt({Size=UDim2.new(0,22,0,22),Position=UDim2.new(1,-54,0.5,-11),BackgroundColor3=C.warn,Text="−",TextSize=14,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},TB); Cr(5,BM)
local Body=Fr({Size=UDim2.new(1,0,1,-38),Position=UDim2.new(0,0,0,38),BackgroundTransparency=1},W)

BC.MouseButton1Click:Connect(function()
    TW:Create(W,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,310,0,0)}):Play()
    task.delay(0.22,function() pcall(function()MG:Destroy()end) pcall(function()NG:Destroy()end) end)
end)
local mini=false
BM.MouseButton1Click:Connect(function()
    mini=not mini; Body.Visible=not mini
    TW:Create(W,TweenInfo.new(0.18),{Size=mini and UDim2.new(0,310,0,38) or UDim2.new(0,310,0,460)}):Play()
end)

local P = 8  -- padding

-- ── SCAN BAR (40px) ───────────────────────────
local scanBar=Fr({Size=UDim2.new(1,-P*2,0,36),Position=UDim2.new(0,P,0,6),BackgroundColor3=C.panel},Body)
Cr(8,scanBar); Sk(C.bF,1,scanBar)
Lb({Size=UDim2.new(0,48,1,0),Position=UDim2.new(0,8,0,0),Text="SCAN:",TextSize=9,Font=Enum.Font.GothamBold,TextColor3=C.muted,TextXAlignment=Enum.TextXAlignment.Left},scanBar)
local scanWord=Lb({Size=UDim2.new(0.52,0,1,0),Position=UDim2.new(0,56,0,0),Text="menunggu...",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.gold,TextXAlignment=Enum.TextXAlignment.Left},scanBar)
Lb({Size=UDim2.new(0.13,0,1,0),Position=UDim2.new(0.74,0,0,0),Text="→",TextSize=13,TextColor3=C.dim},scanBar)
local scanNext=Lb({Size=UDim2.new(0.22,0,1,0),Position=UDim2.new(0.84,0,0,0),Text="—",TextSize=13,Font=Enum.Font.GothamBold,TextColor3=C.accB},scanBar)

-- ── AUTO TOGGLE (25px) ───────────────────────
local autoBar=Fr({Size=UDim2.new(1,-P*2,0,24),Position=UDim2.new(0,P,0,50),BackgroundTransparency=1},Body)

local function SmTgl(xOff, w2, label2, init, cb2)
    local on=init
    local f=Fr({Size=UDim2.new(0,w2,1,0),Position=UDim2.new(0,xOff,0,0),BackgroundColor3=C.panel},autoBar)
    Cr(6,f); Sk(C.bF,1,f)
    Lb({Size=UDim2.new(0.62,0,1,0),Position=UDim2.new(0,7,0,0),Text=label2,TextSize=9,Font=Enum.Font.GothamBold,TextColor3=on and C.accB or C.muted,TextXAlignment=Enum.TextXAlignment.Left},f)
    local pb=Fr({Size=UDim2.new(0,28,0,14),Position=UDim2.new(1,-34,0.5,-7),BackgroundColor3=on and C.accD or Color3.fromRGB(18,22,42)},f); Cr(7,pb)
    local kn=Fr({Size=UDim2.new(0,10,0,10),Position=UDim2.new(on and 1 or 0,on and -13 or 2,0.5,-5),BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted},pb); Cr(5,kn)
    local hit=Bt({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=5},f)
    local lbRef=f:FindFirstChildOfClass("TextLabel")
    hit.MouseButton1Click:Connect(function()
        on=not on
        TW:Create(pb,TweenInfo.new(0.15),{BackgroundColor3=on and C.accD or Color3.fromRGB(18,22,42)}):Play()
        TW:Create(kn,TweenInfo.new(0.15),{Position=on and UDim2.new(1,-13,0.5,-5) or UDim2.new(0,2,0.5,-5),BackgroundColor3=on and Color3.fromRGB(255,255,255) or C.muted}):Play()
        if lbRef then lbRef.TextColor3=on and C.accB or C.muted end
        cb2(on)
    end)
    return f
end

local autoPlay = false
local humanMode = true
SmTgl(0, 138, "AUTO PLAY", false, function(on) autoPlay=on; Notify(on and "AUTO PLAY ON" or "AUTO OFF","info") end)
SmTgl(142, 148, "Human Delay", true, function(on) humanMode=on end)

-- ── PREFIX HEADER (18px) ─────────────────────
local preY = 82
Lb({Size=UDim2.new(1,-P*2,0,16),Position=UDim2.new(0,P,0,preY),
    Text="  PILIH AWALAN KATA",TextSize=9,Font=Enum.Font.GothamBold,
    TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left},Body)
local divPre=Fr({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,preY+16),BackgroundColor3=C.bdr},Body); divPre.BackgroundTransparency=0.6

-- ── PREFIX SCROLL (72px) ─────────────────────
local preSF=Instance.new("ScrollingFrame",Body)
preSF.Size=UDim2.new(1,-P*2,0,70); preSF.Position=UDim2.new(0,P,0,preY+20)
preSF.BackgroundTransparency=1; preSF.BorderSizePixel=0
preSF.ScrollBarThickness=2; preSF.ScrollBarImageColor3=C.acc
preSF.ScrollingDirection=Enum.ScrollingDirection.X
preSF.CanvasSize=UDim2.new(0,0,0,0); preSF.AutomaticCanvasSize=Enum.AutomaticSize.X

local preLayout=Instance.new("UIListLayout",preSF)
preLayout.FillDirection=Enum.FillDirection.Horizontal
preLayout.SortOrder=Enum.SortOrder.LayoutOrder
preLayout.Padding=UDim.new(0,3)
local prePad=Instance.new("UIPadding",preSF); prePad.PaddingRight=UDim.new(0,4)

-- Semua prefix yang ada di DB, diurutkan
local allPrefixes = {}
for k in pairs(DB) do table.insert(allPrefixes, k) end
table.sort(allPrefixes, function(a,b)
    if #a ~= #b then return #a < #b end
    return a < b
end)

-- ── WORD LIST AREA ───────────────────────────
local wordY = preY + 20 + 70 + 6
Lb({Size=UDim2.new(1,-P*2,0,16),Position=UDim2.new(0,P,0,wordY),
    Text="  DAFTAR KATA",TextSize=9,Font=Enum.Font.GothamBold,
    TextColor3=C.acc,TextXAlignment=Enum.TextXAlignment.Left},Body)
local wordCount=Lb({Size=UDim2.new(0.5,0,0,16),Position=UDim2.new(0.5,0,0,wordY),
    Text="",TextSize=9,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Right},Body)
local divWord=Fr({Size=UDim2.new(1,-P*2,0,1),Position=UDim2.new(0,P,0,wordY+16),BackgroundColor3=C.bdr},Body); divWord.BackgroundTransparency=0.6

-- Action bar height = 46
local actH = 46
local wordListH = 460 - 38 - wordY - 16 - 2 - actH - P - 6
local wordSF=Instance.new("ScrollingFrame",Body)
wordSF.Size=UDim2.new(1,-P*2,0,wordListH); wordSF.Position=UDim2.new(0,P,0,wordY+20)
wordSF.BackgroundTransparency=1; wordSF.BorderSizePixel=0
wordSF.ScrollBarThickness=3; wordSF.ScrollBarImageColor3=C.acc
wordSF.CanvasSize=UDim2.new(0,0,0,0); wordSF.AutomaticCanvasSize=Enum.AutomaticSize.Y

local wordLayout=Instance.new("UIGridLayout",wordSF)
wordLayout.CellSize=UDim2.new(0.5,-3,0,32)
wordLayout.CellPadding=UDim2.new(0,4,0,4)
wordLayout.SortOrder=Enum.SortOrder.LayoutOrder
local wPad=Instance.new("UIPadding",wordSF); wPad.PaddingBottom=UDim.new(0,4)

-- ── ACTION BAR (46px) ─────────────────────────
local actY = 460 - 38 - actH - P
local actBar=Fr({Size=UDim2.new(1,-P*2,0,actH),Position=UDim2.new(0,P,0,actY),BackgroundColor3=C.panel},Body)
Cr(8,actBar); Sk(C.bdr,1.5,actBar)
Gd(Color3.fromRGB(14,18,40),Color3.fromRGB(9,12,28),160,actBar)

-- Nama kata terpilih
Lb({Size=UDim2.new(0.35,0,0,14),Position=UDim2.new(0,8,0,4),Text="DIPILIH",TextSize=8,Font=Enum.Font.GothamBold,TextColor3=C.dim,TextXAlignment=Enum.TextXAlignment.Left},actBar)
local selWord=Lb({Size=UDim2.new(0.42,0,0,22),Position=UDim2.new(0,8,0,16),Text="—",TextSize=15,Font=Enum.Font.GothamBold,TextColor3=C.accB,TextXAlignment=Enum.TextXAlignment.Left},actBar)

-- Tombol KETIK
local typeBtn=Bt({Size=UDim2.new(0,86,0,34),Position=UDim2.new(1,-94,0.5,-17),BackgroundColor3=C.accD,Text="⌨  KETIK",TextSize=11,TextColor3=Color3.fromRGB(255,255,255),ZIndex=4},actBar)
Cr(7,typeBtn); Gd(C.accB,C.accD,90,typeBtn)

local curSelWord = nil

typeBtn.MouseButton1Click:Connect(function()
    if not curSelWord then Notif("Pilih kata dulu!","warn"); return end
    Notif("Ketik: "..curSelWord,"ok")
    TypeWord(curSelWord, humanMode)
end)

-- ── WORD LIST BUILDER ─────────────────────────
local prevWordBtn = nil

local function BuildWordList(prefix)
    -- Clear
    for _, c in ipairs(wordSF:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    curSelWord = nil; selWord.Text = "—"; prevWordBtn = nil

    local words = DB[prefix] or {}
    wordCount.Text = #words.." kata"

    if #words == 0 then
        local lb=Instance.new("TextLabel",wordSF)
        lb.Size=UDim2.new(1,0,0,28); lb.BackgroundTransparency=1
        lb.Text="Tidak ada kata untuk '"..prefix.."'"; lb.TextSize=11
        lb.TextColor3=C.dim; lb.Font=Enum.Font.GothamSemibold
        return
    end

    for i, word in ipairs(words) do
        local lastC = word:sub(#word):lower()
        local hasNext = DB[lastC] and #DB[lastC] > 0
        local lastDisp = word:sub(#word):upper()

        local btn=Bt({BackgroundColor3=C.card,Text="",ZIndex=3,LayoutOrder=i},wordSF)
        Cr(6,btn); Sk(C.bF,1,btn)

        -- Nama kata
        Lb({Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,8,0,0),
            Text=word,TextSize=11,Font=Enum.Font.GothamBold,
            TextColor3=C.txt,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},btn)

        -- Badge huruf akhir
        local badgeCol = hasNext and C.ok or C.warn
        local badge=Fr({Size=UDim2.new(0,20,0,18),Position=UDim2.new(1,-24,0.5,-9),BackgroundColor3=badgeCol,ZIndex=4},btn)
        Cr(4,badge); badge.BackgroundTransparency=0.5
        Lb({Size=UDim2.new(1,0,1,0),Text=lastDisp,TextSize=9,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(255,255,255),ZIndex=5},badge)

        btn.MouseButton1Click:Connect(function()
            if prevWordBtn then
                TW:Create(prevWordBtn,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play()
            end
            TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.accD}):Play()
            prevWordBtn = btn
            curSelWord = word
            selWord.Text = word
        end)
        btn.MouseEnter:Connect(function()
            if btn ~= prevWordBtn then TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.cardH}):Play() end
        end)
        btn.MouseLeave:Connect(function()
            if btn ~= prevWordBtn then TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end
        end)
    end
end

-- ── PREFIX BUTTONS ────────────────────────────
local prevPBtn = nil

for ord, prefix in ipairs(allPrefixes) do
    local count = DB[prefix] and #DB[prefix] or 0
    local dispLen = #prefix == 1 and prefix:upper()
                 or prefix:upper()

    local btn=Bt({Size=UDim2.new(0, #prefix == 1 and 30 or (#prefix == 2 and 36 or 42),1,-4),
        BackgroundColor3=C.card,Text=dispLen,
        TextSize=#prefix == 1 and 11 or 10,
        TextColor3=C.muted,Font=Enum.Font.GothamBold,
        LayoutOrder=ord,ZIndex=3},preSF)
    Cr(5,btn)

    -- Dot warna berdasarkan jumlah kata
    local dotC = count>=30 and C.ok or count>=10 and C.warn or C.danger

    btn.MouseButton1Click:Connect(function()
        if prevPBtn then TW:Create(prevPBtn,TweenInfo.new(0.12),{BackgroundColor3=C.card,TextColor3=C.muted}):Play() end
        TW:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.acc,TextColor3=Color3.fromRGB(255,255,255)}):Play()
        prevPBtn = btn
        BuildWordList(prefix)
        Notif(prefix:upper()..": "..count.." kata","info")
    end)
end

-- ══════════════════════════════════════════════════════
-- SCAN LOOP (tiap 0.5 detik — ringan)
-- ══════════════════════════════════════════════════════
local lastAutoWord = ""
local scanConn = RunService.Heartbeat:Connect(function()
    if not W or not W.Parent then
        scanConn:Disconnect(); return
    end
    local now = os.clock()
    if not W._lastScan then W._lastScan = 0 end
    if now - W._lastScan < 0.5 then return end
    W._lastScan = now

    local detected = ScanScreen()
    if detected and detected ~= "" then
        -- Update scan bar
        scanWord.Text = detected

        -- Huruf terakhir dari kata yang terdeteksi
        local lastCh = detected:sub(#detected):lower()
        local prefix1 = lastCh
        -- 2 char terakhir juga coba
        local prefix2 = #detected >= 2 and detected:sub(#detected-1):lower() or nil

        -- Update next hint
        if DB[prefix1] and #DB[prefix1] > 0 then
            local hw = FindBestWord(prefix1)
            scanNext.Text = hw or "—"
        else
            scanNext.Text = "—"
        end

        -- AUTO PLAY
        if autoPlay and detected ~= lastAutoWord then
            lastAutoWord = detected
            local nextW = FindBestWord(lastCh)
            if nextW and not typing then
                curSelWord = nextW
                selWord.Text = nextW
                -- Auto scroll ke huruf prefix
                for _, btn in ipairs(preSF:GetChildren()) do
                    if btn:IsA("TextButton") and btn.Text:lower() == prefix1 then
                        if prevPBtn then TW:Create(prevPBtn,TweenInfo.new(0.1),{BackgroundColor3=C.card,TextColor3=C.muted}):Play() end
                        TW:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.acc,TextColor3=Color3.fromRGB(255,255,255)}):Play()
                        prevPBtn = btn
                        BuildWordList(prefix1)
                        break
                    end
                end
                task.spawn(function()
                    task.wait(0.5 + math.random()*0.5)
                    TypeWord(nextW, humanMode)
                end)
                Notif("AUTO → "..nextW,"ok")
            end
        end
    end
end)

-- ── ENTRANCE ──────────────────────────────────
W.Position=UDim2.new(0,8,1.5,0); W.BackgroundTransparency=1
TW:Create(W,TweenInfo.new(0.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Position=UDim2.new(0,8,0.5,-230), BackgroundTransparency=0,
}):Play()

task.delay(0.5,function()
    Notif("VOID HUB • Sambung Kata v2 loaded!","ok")
    task.delay(1.2,function()
        Notif("Database: "..#allPrefixes.." prefix tersedia","info")
    end)
end)

-- Auto pilih prefix "a" di awal
task.delay(0.9, function()
    for _, btn in ipairs(preSF:GetChildren()) do
        if btn:IsA("TextButton") and btn.Text == "A" then
            TW:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=C.acc,TextColor3=Color3.fromRGB(255,255,255)}):Play()
            prevPBtn = btn
            BuildWordList("a")
            break
        end
    end
end)
 
