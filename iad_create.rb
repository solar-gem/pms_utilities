# coding: utf-8

# Скрипт для формирования файла с данными автоматического создания станции на сервере измерений.
# Возможный тип оборудовария UAD или IAD.
# Данное оборудование уже должно быть прописано на SoftX.
# По имеющемуся IP в SoftX выбираем нумерацию и формируем диапазоны.
# Создаем файл для загрузки в сервер измерений.


### Добавление в поиск частей программы директорию из которой запустили данный файл
### $:.unshift(File.dirname(__FILE__) + "/lib")
# Библиотека подключения к станциям
require 'commutation_system'



# Получение массива с диапазонами номеров
def create_span()
  # Создаем подключение к станции
	softx = CommutationSystem::SoftX.new(:host => "10.200.16.8",
		:username => "opts270",
		:password => "270270")

	if softx.connection_telnet.connect
	  unless softx.connection_telnet.login
		puts 'Не удалось подключиться к станции или авторизироваться'
		softx.connection_telnet.close
		exit
	  end
	end

	data_MGW = softx.connection_telnet.cmd("LST MGW: IPADDR=\"#{@iad_ip}\";")
	if equipment_id = data_MGW[:data][/Equipment ID  =  \S+/].sub(/Equipment ID  =  /,'')
	  puts "Equipment ID найден: #{equipment_id}"
	else
	  puts 'Equipment ID найден'
	  exit
	end

	sub = []
	data_VSBR = softx.connection_telnet.cmd("LST VSBR: EID=\"#{equipment_id}\", MRR=100000;")
	 #Закрываем соединение со станцией
	 softx.connection_telnet.close


	data_VSBR[:data].scan(/\d{#{@iad_num}}/){|q| sub << @iad_code + q}

	# Формируем массив с диапазонами номеров
	_is = sub.sort # Массив с номерами на IAD
	result = [] # Массив с диапазанами

	res = ""
	_is.each_index do |q|
	  res << (_is[q].to_s + ' ') if q == 0
      if _is[q].succ != _is[q + 1]
        res << _is[q].to_s
	    result << res
	    res = ''
	    #res << ',' if q != (_is.length - 1)
	    res << (_is[q + 1].to_s + ' ') if q != (_is.length - 1)
       end
    end

	result
end



print "Введите имя создаваемого файла: "
@name_out_file = gets.chomp!.to_s << ".txt"

print "Введите тип оборудования [uad/iad]: "
@type_uad = gets.chomp!

print "Нужно создавать новый канал на сервере измерений [Y/N]: "
_create_chenel = gets.chomp!
@create_chenel = false
@create_chenel = true if ("Y" == _create_chenel || "y" == _create_chenel)

    print "Введите IP #{@type_uad}: "
	@iad_ip = gets.chomp!
	print 'Введите кол-во цифр в номере: '
	@iad_num = gets.chomp!
	print 'Введите код города: '
	@iad_code = gets.chomp!
	print 'Введите имя IAD на сервере измерений: '
	@iad_name = gets.chomp!
	print 'Введите имя пользователя для доступа ЦБР: '
  @iad_user = gets.chomp!
  print 'Введите пароль для доступа ЦБР: '
  @iad_password = gets.chomp!

  array_numbers = create_span # Находим диапазоны номеров
  case @type_uad
  when 'iad'
    @type_uad = 'iad2000'
  when 'uad'
    @type_uad = 'honet'
  end


  if array_numbers.length > 0
    File.open(@name_out_file, "a+") do |file|
	    # Формируем данные по созданию станции с нумерацией
		array_numbers.each do |number|
		  file.puts "create_ats \"#{@iad_name}\" #{@type_uad} #{number}"
		end
		# Формируем данные по созданию канала
		file.puts "create_channel \"#{@iad_name}\" \"#{@type_uad}\" \"#{@iad_ip}\" \"23\" \"#{@iad_user}\" \"#{@iad_password}\""
		file.puts "clinks \"#{@iad_name}\" \"#{@iad_name}\""
        file.puts "enable_channel \"#{@iad_name}\""
    end

  else
    puts "На станции не найден ни один диапазон номеров для данного оборудования!"
  end

  puts "Для завершения нажмите Enter."
  gets

  #line = create_str
  #File.open(@name_out_file, "a+"){|file| file.puts line}







