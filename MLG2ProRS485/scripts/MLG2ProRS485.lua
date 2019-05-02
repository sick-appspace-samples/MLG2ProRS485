--[[----------------------------------------------------------------------------

  Application Name:
  MLG2ProRS485

  Summary:
  Connecting and communicating to a MLG-2 Pro device with serial interface RS 485

  Description:
  This sample shows how to connect to a MLG-2 Pro device with serial interface RS 485.
  Measuring data is received.

  How to run:
  This sample can be run on any AppSpace device which contain a serial interface
  RS 485, e.g. SIM family. The MLG-2 Pro device with a serial interface must be properly
  connected to a serial port of the AppSpace device. If a device is powered over
  the serial port of the AppSpace device the LED of the port is turned on. If data
  is sent or received on the serial interface the LED of the port blinks.

  More Information:
  See device manual of AppSpace device with serial interface for according ports.
  See manual of connected remote device with serial interface for further interface
  specific description and device specific commands.

------------------------------------------------------------------------------]]
--Start of Global Scope---------------------------------------------------------

-- luacheck: globals gPowerSer1 gComSer1

-- Enable power on Serial port 1, must be adapted if another port is used
gPowerSer1 = Connector.Power.create('SER1')
Connector.Power.enable(gPowerSer1, true)

--End of Global Scope-----------------------------------------------------------

--Start of Function and Event Scope---------------------------------------------

-- Wait for boot up of conencted device after power is enabled
Script.sleep(3000)

-- Creating serial port for serial port 1, must be adapted if another port is used
-- Serial interface settings are configured corresponding to connected device
gComSer1 = SerialCom.create('SER1')
SerialCom.setType(gComSer1, 'RS485')
SerialCom.setTermination(gComSer1, true)
SerialCom.setDataBits(gComSer1, 8)
SerialCom.setStopBits(gComSer1, 1)
SerialCom.setParity(gComSer1, 'N')
SerialCom.setBaudRate(gComSer1, 9600)
SerialCom.setFraming(gComSer1, '\02', '\03', '\02', '\03') -- STX/ETX framing for transmit and receive

local function handleReceiveSer1(data)
  -- Received data is processed to extract the relevant information, this needs to be
  -- adapted to the connected device.
  -- This example works with a SICK MLG-2 Pro - data output is set to 16 bit decimal values with SOPAS ET
  local systemStatus = tonumber(string.sub(data, 1, 3))
  local outputStatus = tonumber(string.sub(data, 4, 6))
  local nbb = tonumber(string.sub(data, 7, 9))
  local lbb = tonumber(string.sub(data, 10, 12))
  local fbb = tonumber(string.sub(data, 13, 15))
  local odi = tonumber(string.sub(data, 16, 18))
  local idi = tonumber(string.sub(data, 19, 21))
  print(
    'MLG - system status: ' ..
      systemStatus ..
        ' output status: ' ..
          outputStatus ..
            ' NBB: ' ..
              nbb ..
                ' LBB: ' ..
                  lbb .. ' FBB: ' .. fbb .. ' ODI: ' .. odi .. ' IDI: ' .. idi
  )
end

SerialCom.register(gComSer1, 'OnReceive', handleReceiveSer1)
-- Establish/acivate the serial interface
local isOpen = SerialCom.open(gComSer1)
if (not isOpen) then
  print('could not open serial port.')
end
--End of Function and Event Scope-----------------------------------------------
