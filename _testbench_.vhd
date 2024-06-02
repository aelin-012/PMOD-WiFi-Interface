--Testbench Module--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_Module_TB is
end Top_Module_TB;

architecture Behavioral of Top_Module_TB is
    constant CLK_PERIOD : time := 10 ns; -- Clock period (100 MHz)
    
    signal clk_tb : std_logic := '0'; -- Testbench clock signal
    signal reset_tb : std_logic := '0'; -- Testbench reset signal
    signal wifi_rx_tb : std_logic_vector(7 downto 0) := (others => '0'); -- Testbench wifi_rx stimulus
    signal uart_rx_tb : std_logic := '0'; -- Testbench uart_rx stimulus
    signal uart_tx_tb : std_logic; -- Testbench uart_tx monitor
    signal uart_rx_data_tb : std_logic_vector(7 downto 0); -- Testbench uart_rx_data monitor
    signal uart_rx_ready_tb : std_logic; -- Testbench uart_rx_ready monitor
    signal uart_tx_ready_tb : std_logic := '1'; -- Testbench uart_tx_ready monitor
    signal wifi_tx_tb : std_logic_vector(7 downto 0); -- Testbench wifi_tx monitor

    -- Instantiate the DUT (Device Under Test)
    component Top_Module
        Port ( 
           clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           wifi_rx : in STD_LOGIC_VECTOR(7 downto 0);
           wifi_tx : out STD_LOGIC_VECTOR(7 downto 0);
           wifi_ready : out STD_LOGIC;
           uart_rx : in STD_LOGIC;
           uart_tx : out STD_LOGIC;
           uart_rx_data : out STD_LOGIC_VECTOR(7 downto 0);
           uart_tx_data : in STD_LOGIC_VECTOR(7 downto 0); -- Add uart_tx_data port here
           uart_rx_ready : out STD_LOGIC;
           uart_tx_ready : in STD_LOGIC
         );
    end component;

begin
    -- Connect DUT
    DUT : Top_Module port map (
        clk => clk_tb,
        reset => reset_tb,
        wifi_rx => wifi_rx_tb,
        wifi_tx => wifi_tx_tb,
        wifi_ready => open, -- Not monitoring wifi_ready in this testbench
        uart_rx => uart_rx_tb,
        uart_tx => uart_tx_tb,
        uart_rx_data => uart_rx_data_tb,
        uart_tx_data => (others => '0'), -- Example: Sending all zeros for uart_tx_data in this testbench
        uart_rx_ready => uart_rx_ready_tb,
        uart_tx_ready => uart_tx_ready_tb -- Removed uart_tx_data port here
    );

    -- Clock generation process
    clk_process: process
    begin
        while now < 500 ns loop -- Run for 500 ns
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        reset_tb <= '1'; -- Assert reset
        wait for 20 ns;
        reset_tb <= '0'; -- De-assert reset
        wait for 10 ns;
        
        -- Send some data to wifi_rx
        wifi_rx_tb <= "01010101";
        wait for 50 ns;
        
        -- Another data
        wifi_rx_tb <= "11001100";
        wait for 50 ns;

        -- Send some data to uart_rx
        uart_rx_tb <= '1';
        wait for 10 ns;
        uart_rx_tb <= '0';
        wait for 30 ns;
        
        -- Another data
        uart_rx_tb <= '1';
        wait for 20 ns;
        uart_rx_tb <= '0';
        wait for 40 ns;

        -- Add more test cases as needed

        wait for 400 ns; -- Allow some time for simulation to complete
        wait;
    end process;

end Behavioral;

