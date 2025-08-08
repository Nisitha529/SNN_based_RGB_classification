-- video_generator.vhd
--
-- generate a simple 720p video signal
--   this project is an introduction to FPGA design
--   hardware implementation can be done with the FPGA Vision Remote Lab of Hochschule Bonn-Rhein-Sieg, Germany
--
-- timing information for a 720p signal can be found in online sources
--   720p uses a 74.25 MHz clock that is provided as an input signal
--   vertical timing is 720 active lines plus 30 inactive lines (blanking)
--   horizontal timing is 1280 active pixel plus 370 inactive pixel
--   more info on sync timing, back porch, front porch is found online and used in the code below
--
-- FPGA Vision Remote Lab http://h-brs.de/fpga-vision-lab
-- (c) Marco Winzker, Hochschule Bonn-Rhein-Sieg, 05.02.2025
--   24.6.2025   added comments for video lecture

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity video_generator is
  port (clk       : in  std_logic;                      -- input clock 74.25 MHz, video 720p
        reset_n   : in  std_logic;                      -- reset (invoked during configuration)
        enable_in : in  std_logic_vector(2 downto 0);   -- three slide switches
        -- video out
        vs_out    : out std_logic;                      -- vertical sync signal
        hs_out    : out std_logic;                      -- horizontal sync signal                      
        de_out    : out std_logic;                      -- data enable, i.e. active pixel
        r_out     : out std_logic_vector(7 downto 0);   -- red
        g_out     : out std_logic_vector(7 downto 0);   -- green
        b_out     : out std_logic_vector(7 downto 0);   -- blue image information
        --
        clk_o     : out std_logic);                      -- output clock (do not modify)

end video_generator;

architecture behave of video_generator is

    -- input signals
    signal reset                 	: std_logic;
    signal enable                 	: std_logic_vector(2 downto 0);
    -- internal signals
    signal h_count     		        : integer range 0 to 2047 := 0;
    signal v_count     		        : integer range 0 to 1023 := 0;
    signal new_frame             	: std_logic;
    signal hs, vs, de            	: std_logic;
    signal r, g, b            		: std_logic_vector(7 downto 0);
    signal h_start	                : integer range 0 to 2047 := 600;
    signal h_end	                : integer range 0 to 2047 := 700;

begin
	
process
begin	
  wait until rising_edge(clk);

    -- input signals need an input flip-flop (except clock)
    reset  <= not reset_n; -- reset, invert for positive logic
    enable <= enable_in;   -- three control switches

    -- use reset for control signals
    if (reset = '1') then
        h_count   <= 0;
        v_count   <= 0;
        new_frame <= '0';
    else
        new_frame  <= '0'; -- default
        -- count total pixel of a line
        if (h_count < 1650-1 ) then
                h_count <= h_count + 1;
        else 
            h_count <= 0;
            -- count total lines of a frame
            if (v_count < 750-1 ) then
                v_count <= v_count + 1;
            else 
                v_count <= 0;
                new_frame  <= '1'; -- indicate new frame for one clock cycle
            end if; -- v_count
        end if; -- h_count
    end if; -- reset

    -- timing for horizontal sync
    if ( h_count < 40 ) then
         hs <= '1'; else
         hs <= '0'; end if;

    -- timing for vertical sync
    if ( v_count < 5 ) then
        vs <= '1'; else
        vs <= '0'; end if;

    -- check if active image
    -- from back_porch to back_porch+active_lines/column (back_porch is at beginning of row/column)
    if ( h_count >= 220 and h_count < (220+1280) and
         v_count >=  20 and v_count < ( 20+ 720) ) then
        -- active image, set to gray
        de <= '1';
        r  <= "10000000";
        g  <= "10000000";
        b  <= "10000000";
    else
        -- blanking, i.e. no image, set to black
        de <= '0';
        r  <= "00000000";
        g  <= "00000000";
        b  <= "00000000";
    end if;

    -- make one red square
    if ( h_count >= 400 and h_count < 500 and
         v_count >= 200 and v_count < 300 ) then
        -- set to red
        r  <= "11111111";
        g  <= "00000000";
        b  <= "00000000";
    end if;

    -- make one moving green square
    if (reset = '1' or h_start=800) then
        h_start   <= 600;
        h_end     <= 700;
    elsif (new_frame = '1') then
        -- move the square by one pixel for each frame
        h_start   <= h_start+1;
        h_end     <= h_end  +1;
    end if;
    
    if ( h_count >= h_start and h_count < h_end and
         v_count >= 400     and v_count < 500   ) then
        -- set to green
        r  <= "00000000";
        g  <= "11111111";
        b  <= "00000000";
    end if;

    -- give the signals to the output
    vs_out  <= vs;
    hs_out  <= hs;
    de_out  <= de;
    r_out   <= r; 
    g_out   <= g;
    b_out   <= b;	 

end process;

-- do not modify
clk_o <= clk;

end behave;