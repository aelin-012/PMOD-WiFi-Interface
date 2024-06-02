--UART Interface--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        rx : in STD_LOGIC;
        tx : out STD_LOGIC;
        rx_data : out STD_LOGIC_VECTOR(7 downto 0);
        rx_ready : out STD_LOGIC;
        tx_data : in STD_LOGIC_VECTOR(7 downto 0);
        tx_ready : in STD_LOGIC
    );
end UART;

architecture Behavioral of UART is
    constant BAUD_RATE : integer := 9600; -- Baud rate (bps)
    constant CLOCK_FREQ : integer := 100000000; -- Clock frequency (Hz)

    signal bit_count : integer range 0 to 10 := 0; -- Bit counter
    signal shift_reg : std_logic_vector(9 downto 0) := (others => '0'); -- Shift register
    signal tx_busy : std_logic := '0'; -- Transmit busy signal

begin
    -- UART process
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset state
                bit_count <= 0;
                shift_reg <= (others => '0');
                tx_busy <= '0';
            else
                -- Receive data
                if rx = '0' and bit_count = 0 then
                    -- Start bit detected
                    bit_count <= 1;
                elsif bit_count > 0 and bit_count < 9 then
                    -- Data bits
                    shift_reg(bit_count) <= rx;
                    bit_count <= bit_count + 1;
                elsif bit_count = 9 then
                    -- Stop bit
                    rx_ready <= '1';
                    bit_count <= 0;
                end if;

                -- Transmit data
                if tx_ready = '1' and tx_busy = '0' then
                    if bit_count = 0 and shift_reg(0) = '0' then
                        -- Start transmission
                        shift_reg <= '0' & tx_data & '1'; -- Start bit + data bits + stop bit
                        tx_busy <= '1';
                        bit_count <= 1;
                    elsif bit_count > 0 and bit_count < 10 then
                        -- Transmit data bits
                        tx <= shift_reg(0);
                        shift_reg <= '0' & shift_reg(9 downto 1); -- Shift out data bits
                        bit_count <= bit_count + 1;
                        if bit_count = 10 then
                            -- Transmission complete
                            tx_busy <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Assign receive data
    rx_data <= shift_reg(8 downto 1);
    rx_ready <= '0';

end Behavioral;

