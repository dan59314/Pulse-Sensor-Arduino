/*
Timer0 - An 8 bit timer used by Arduino functions delay(), millis() and micros().
Timer1 - A 16 bit timer used by the Servo() library
Timer2 - An 8 bit timer used by the Tone() library

Timer_output Arduino_output  Chip_pin  Pin_name
OC0A (Timer0)     6             12        PD6
OC0B (Timer0)     5             11        PD5
OC1A (Timer1)     9             15        PB1
OC1B (Timer1)     10            16        PB2
OC2A (Timer2)     11            17        PB3
OC2B (Timer2)     3             5         PD3

使用 tone() 將和 pin 3, pin 11 衝突
*/

const float cPreScale = 256.0;  // Timer2不支援1024 Prescale. 256效果最好，1024 波形漂亮，數值越大，精度越低，細節越少。

void interruptTimer2Setup(int timer2IntervalMsec)
{
	// timer2IntervalMsec:　設定Interrupt 產生的間隔　毫秒
	
	/*
	// turn on CTC mode
  TCCR2A |= (1 << WGM21);
  // Set CS21 bit for 8 prescaler
  TCCR2B |= (1 << CS21);   
  // enable timer compare interrupt
  TIMSK2 |= (1 << OCIE2A);
	*/

	// TCCRxx(Timer/Counter Control Register) --------------------------------------------
	TCCR2A = 0x02;     // 取消timer2, pin3,11 pwm, 進入比對吻合清除模式 CTC(Clear Time on Compare match) MODE
	TCCR2B = 0x06;     // 不強迫比對並使用 256 PRESCALER 
	
	
	// SET THE TOP OF THE COUNT TO 124 (16MHz/256/500 = 125, because index start from 0, so count=124) 
	// FOR 500Hz SAMPLE PulseDurations, 500 Hz/sec =>  1000 msec/500 -> 2 MSec 
	//OCR2A = 0X7C;     
	float scaledFrequency = 16000000.0 / cPreScale;  // 使用 PreScale 256，降低中斷檢查頻率
	float wantedFrequency = 1.0 / (timer2IntervalMsec / 1000.0);  //計算間隔毫秒的頻率
	int tickCount = scaledFrequency / wantedFrequency;  //縮頻除以設定的頻率 = 比對的TickCount值
	OCR2A = tickCount - 1; //OCR(Output Compare Register) 溢位值  ( 16,000,000Hz/ (prescaler * desired interrupt frequency) ) - 1

#ifdef debug
	Serial.print("Scaled Frequency: ");  Serial.println(scaledFrequency);
	Serial.print("Wanted Frequency: "); Serial.println(wantedFrequency);
	Serial.print("TickCount: "); Serial.println(tickCount);
#endif

	TIMSK2 = 0x02;     // 啟動　Timer2　溢位中斷
	sei();             // MAKE SURE GLOBAL INTERRUPTS ARE ENABLED      
}


// TIMER 2 INTERRUPT SERVICE ROUTINE -----------------------------------------------------------------------
ISR(TIMER2_COMPA_vect)  // triggered when Timer2 counts to 124,  0~124 = 125
{
#ifdef debug
	//Serial.print('Tick: ');  Serial.println(millis()); 
#endif

	cli();                                      // disable interrupts	

	OnTimer2Interrupt();

	sei();                                   // enable interrupts when youre done!


//#ifdef debug
	//Serial.print('Finish OnTimer2Interrupt(): ');  Serial.println(millis());
//#endif
}





