library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snn_neuron_2input is
    generic(
        w_0    : integer := 1;   -- Weight for input 0
        w_1    : integer := 1;   -- Weight for input 1
        bias   : integer := 0;   -- Bias value
        v_th   : integer := 4;   -- Threshold voltage
        leak   : integer := 100  -- Leak factor (100 = 10% leak)
    );
    port(
        clk          : in  std_logic;   -- System clock
        reset        : in  std_logic;   -- Global reset
        sp_0         : in  std_logic;   -- Input spike 0
        sp_1         : in  std_logic;   -- Input spike 1
        neuron_reset : in  std_logic;   -- Neuron-specific reset
        spike_out    : out std_logic    -- Output spike
    );
end snn_neuron_2input;

architecture Behavioral of snn_neuron_2input is
    signal voltage : integer := 0;  -- Membrane potential
begin
    process(clk)
        variable current_sum : integer;
        variable new_voltage : integer;
    begin
        if rising_edge(clk) then
            -- Synchronous reset has priority
            if reset = '1' or neuron_reset = '1' then
                voltage <= 0;
                spike_out <= '0';
            else
                -- Calculate weighted sum of inputs
                current_sum := bias;
                if sp_0 = '1' then current_sum := current_sum + w_0; end if;
                if sp_1 = '1' then current_sum := current_sum + w_1; end if;
                
                -- Apply leak and add inputs
                -- Fixed-point arithmetic: leak = 100 means 10% leak (100/1000 = 0.1)
                new_voltage := (voltage * (1000 - leak)) / 1000 + current_sum;
                
                -- Threshold check and spike generation
                if new_voltage >= v_th then
                    voltage <= new_voltage - v_th;  -- Reset by subtraction
                    spike_out <= '1';
                else
                    voltage <= new_voltage;
                    spike_out <= '0';
                end if;
            end if;
        end if;
    end process;
end Behavioral;